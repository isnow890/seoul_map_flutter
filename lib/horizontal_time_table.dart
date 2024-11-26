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

  // 시간 범위 계산
  (int, int) _calculateTimeRange() {
    int minHour = 24;
    int maxHour = 0;

    for (var protest in widget.protests) {
      final startHour = int.parse(protest.startTime.split(':')[0]);
      final endHour = int.parse(protest.endTime.split(':')[0]);
      // 종료 시간이 정각이 아닌 경우를 위해 1시간 추가
      final endHourAdjusted =
          int.parse(protest.endTime.split(':')[1]) > 0 ? endHour + 1 : endHour;

      minHour = min(minHour, startHour);
      maxHour = max(maxHour, endHourAdjusted);
    }

    // 앞뒤로 1시간씩 여유 추가
    minHour = max(0, minHour - 1);
    maxHour = min(24, maxHour + 1);

    return (minHour, maxHour);
  }

  @override
  void initState() {
    super.initState();
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
      height: 50 + (maxRow * 60),
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
                // 왼쪽 여백
                const SizedBox(width: 10),
                // 스크롤 가능한 시간대
                Expanded(
                  child: SingleChildScrollView(
                    controller: _headerScrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: SizedBox(
                      width: totalWidth,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: totalHours,
                        itemBuilder: (context, index) {
                          final hour = startHour + index;
                          return SizedBox(
                            width: hourWidth,
                            child: Center(
                              child: Text(
                                '${hour.toString().padLeft(2, '0')}:00',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          );
                        },
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
                const SizedBox(width: 10),
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
        top: row * 70.0, // 간격을 70으로 늘림
        width: width,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 50, // 최소 높이 설정
          ),
          decoration: BoxDecoration(
            color: protest.color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.blue.shade200),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // 내용에 맞게 크기 조정
            children: [
              Text(
                protest.title,
                style: TextStyle(
                  color: Colors.blue.shade900,
                  fontSize: 12,
                ),
                softWrap: true, // 텍스트 줄바꿈 허용
                maxLines: null, // 최대 라인 수 제한 없음
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
      );
    }).toList();
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
