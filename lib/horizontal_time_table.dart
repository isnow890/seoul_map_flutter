import 'package:flutter/material.dart';
import 'dart:math' show max, min;

import 'package:seoul_map_flutter/time_table.dart';

class HorizontalTimeTable extends StatefulWidget {
  final List<Protest> protests;

  const HorizontalTimeTable({
    super.key,
    required this.protests,
  });

  @override
  State<HorizontalTimeTable> createState() => _HorizontalTimeTableState();
}

class _HorizontalTimeTableState extends State<HorizontalTimeTable> {
  final ScrollController _headerScrollController = ScrollController();
  final ScrollController _timelineScrollController = ScrollController();

  static const double hourWidth = 120.0;
  static const double headerHeight = 50.0;
  static const double rowHeight = 70.0;
  static const double minContainerHeight = 50.0;
  @override
  void initState() {
    super.initState();

    // 스크롤 동기화
    _headerScrollController.addListener(() {
      if (_headerScrollController.offset != _timelineScrollController.offset) {
        _timelineScrollController.jumpTo(_headerScrollController.offset);
      }
    });

    _timelineScrollController.addListener(() {
      if (_timelineScrollController.offset != _headerScrollController.offset) {
        _headerScrollController.jumpTo(_timelineScrollController.offset);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // BuildContext가 준비된 후 스크롤 위치 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentTime();
    });
  }

  DateTime get koreanTime {
    // 한국 시간 (UTC+9) 구하기
    final now = DateTime.now();
    final utcPlus9 = now.toUtc().add(const Duration(hours: 9));
    return utcPlus9;
  }

  void _scrollToCurrentTime() {
    if (!mounted) return;

    final timeRange = _calculateTimeRange();
    final startHour = timeRange.$1;
    final now = koreanTime; // 한국 시간 사용

    // 현재 시간까지의 픽셀 위치 계산
    final currentHour = now.hour;
    final currentMinute = now.minute;

    print('Current time: $currentHour:$currentMinute'); // 디버깅용
    print('Start hour: $startHour'); // 디버깅용

    final scrollPosition = ((currentHour - startHour) * hourWidth +
            (currentMinute / 60.0 * hourWidth))
        .toDouble();

    final screenWidth = MediaQuery.of(context).size.width - 20.0;
    final targetScrollPosition = max(0.0, scrollPosition - (screenWidth / 2));

    print('Target scroll position: $targetScrollPosition'); // 디버깅용

    // 스크롤 컨트롤러가 부착되어 있는지 확인
    if (_headerScrollController.hasClients) {
      _headerScrollController.animateTo(
        targetScrollPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // 시간 범위 계산
  (int, int) _calculateTimeRange() {
    int minHour = 24;
    int maxHour = 0;

    for (var protest in widget.protests) {
      final startHour = int.parse(protest.startTime.split(':')[0]);
      final endHour = int.parse(protest.endTime.split(':')[0]);
      final endHourAdjusted =
          int.parse(protest.endTime.split(':')[1]) > 0 ? endHour + 1 : endHour;

      minHour = min(minHour, startHour);
      maxHour = max(maxHour, endHourAdjusted);
    }

    minHour = max(0, minHour - 1);
    maxHour = min(24, maxHour + 1);

    return (minHour, maxHour);
  }

  @override
  void dispose() {
    _headerScrollController.dispose();
    _timelineScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeRange = _calculateTimeRange();
    final startHour = timeRange.$1;
    final endHour = timeRange.$2;
    final totalHours = endHour - startHour + 1;
    final totalWidth = hourWidth * totalHours;

    final protestsWithRow = _assignRowsToProtests(widget.protests);
    final maxRow = protestsWithRow.map((p) => p.$2).reduce(max) + 1;

    return SizedBox(
      height: 200 + (maxRow * 60),
      child: Column(
        children: [
          // 상단 시간 눈금
          Container(
            height: 50,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                // const SizedBox(width: 10),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _headerScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: SizedBox(
                      width: totalWidth,
                      child: Row(
                        children: List.generate(totalHours, (index) {
                          final hour = startHour + index;
                          final isCurrentHour = hour == koreanTime.hour;

                          return SizedBox(
                            width: hourWidth,
                            child: Container(
                              padding: const EdgeInsets.only(left: 8),
                              alignment: Alignment.centerLeft,
                              decoration: BoxDecoration(
                                border: Border(
                                  right: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                color: isCurrentHour
                                    ? Colors.blue.withOpacity(0.1)
                                    : null,
                              ),
                              child: Text(
                                '${hour.toString().padLeft(2, '0')}:00',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isCurrentHour
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 타임라인 영역
          Expanded(
            child: Row(
              children: [
                // const SizedBox(width: 10),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _timelineScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: SizedBox(
                      width: totalWidth,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _buildGridLines(totalHours),
                          if (_isCurrentTimeVisible(startHour, endHour))
                            _buildCurrentTimeLine(startHour),
                          ..._buildProtestBlocks(protestsWithRow, startHour),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isCurrentTimeVisible(int startHour, int endHour) {
    final now = koreanTime.hour;
    return now >= startHour && now <= endHour;
  }

  Widget _buildCurrentTimeLine(int startHour) {
    final minutesSinceStart =
        ((koreanTime.hour - startHour) * 60 + koreanTime.minute).toDouble();
    final position = minutesSinceStart * (hourWidth / 60);

    return Positioned(
      left: position,
      top: 0,
      bottom: 0,
      child: Container(
        width: 2,
        color: Colors.red.withOpacity(0.5),
      ),
    );
  }

  Widget _buildGridLines(int totalHours) {
    return Row(
      children: List.generate(totalHours, (index) {
        return Container(
          width: hourWidth,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
          ),
        );
      }),
    );
  }

  List<Widget> _buildProtestBlocks(
      List<(Protest, int)> protestsWithRow, int startHour) {
    const pixelsPerMinute = hourWidth / 60;

    return protestsWithRow.map((protestWithRow) {
      final protest = protestWithRow.$1;
      final row = protestWithRow.$2;

      final startMinutes = _timeToMinutes(protest.startTime, startHour);
      final duration = _calculateDuration(protest.startTime, protest.endTime);

      final left = startMinutes * pixelsPerMinute;
      final width = duration * pixelsPerMinute;

      return Positioned(
        left: left,
        top: row * 70.0,
        width: width,
        child: GestureDetector(
          onTap: () {
            // 탭 이벤트 처리
            _onProtestTapped(protest);
          },
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 50,
            ),
            decoration: BoxDecoration(
              color: protest.color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.blue.shade200),
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  protest.title,
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontSize: 12,
                  ),
                  softWrap: true,
                  maxLines: null,
                ),
                const SizedBox(height: 4),
                Text(
                  '${protest.startTime}-${protest.endTime}',
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  void _onProtestTapped(Protest protest) {
    // 탭된 항목의 세부 정보를 표시하거나 다른 동작 수행
    print('Tapped protest: ${protest.title}');
    // TODO: 세부 정보 화면으로 이동하는 등의 동작 구현
  }

  double _timeToMinutes(String time, int startHour) {
    final parts = time.split(':');
    final hours = int.parse(parts[0]) - startHour;
    final minutes = int.parse(parts[1]);
    return (hours * 60 + minutes).toDouble();
  }

  double _calculateDuration(String startTime, String endTime) {
    final startParts = startTime.split(':');
    final endParts = endTime.split(':');
    final startHour = int.parse(startParts[0]);
    final startMinute = int.parse(startParts[1]);
    final endHour = int.parse(endParts[0]);
    final endMinute = int.parse(endParts[1]);
    return ((endHour - startHour) * 60 + (endMinute - startMinute)).toDouble();
  }

  List<(Protest, int)> _assignRowsToProtests(List<Protest> protests) {
    final sortedProtests = List<Protest>.from(protests)
      ..sort((a, b) {
        final aMinutes = _timeToMinutes(a.startTime, 0);
        final bMinutes = _timeToMinutes(b.startTime, 0);
        if (aMinutes != bMinutes) {
          return aMinutes.compareTo(bMinutes);
        }
        final aDuration = _calculateDuration(a.startTime, a.endTime);
        final bDuration = _calculateDuration(b.startTime, b.endTime);
        return bDuration.compareTo(aDuration);
      });

    final result = <(Protest, int)>[];
    final rowEndTimes = <double>[];

    for (final protest in sortedProtests) {
      final startTime = _timeToMinutes(protest.startTime, 0);
      var row = 0;

      while (row < rowEndTimes.length) {
        if (rowEndTimes[row] <= startTime) {
          break;
        }
        row++;
      }

      if (row == rowEndTimes.length) {
        rowEndTimes.add(0);
      }

      rowEndTimes[row] = _timeToMinutes(protest.endTime, 0);
      result.add((protest, row));
    }

    return result;
  }
}
