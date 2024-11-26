import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:seoul_map_flutter/horizontal_time_table.dart';

class ProtestInfoScreen extends StatelessWidget {
  final List<Protest> protests = [
    Protest(
      title: '평강제일교회 앞 <오류동>',
      startTime: '09:30',
      endTime: '11:00',
      color: Colors.blue[100]!,
    ),
    Protest(
      title: '평강교회 정문 좌측 공터 <오류동>',
      startTime: '09:30',
      endTime: '10:30',
      color: Colors.blue[100]!,
    ),
    Protest(
      title: '동화면세점~코리아나호텔 앞 편도 全 차로 <세종대로>',
      startTime: '11:00',
      endTime: '13:30',
      color: Colors.blue[100]!,
    ),
    Protest(
      title: 'test test',
      startTime: '11:00',
      endTime: '12:30',
      color: Colors.blue[100]!,
    ),
    Protest(
      title: 'test test!!!!',
      startTime: '11:00',
      endTime: '12:30',
      color: Colors.blue[100]!,
    ),
    Protest(
      title: 'test test!!!!!',
      startTime: '11:00',
      endTime: '12:30',
      color: Colors.blue[100]!,
    ),
    Protest(
      title: '서울역 4出→CJ대한통운',
      startTime: '13:00',
      endTime: '16:00',
      color: Colors.blue[100]!,
    ),
    Protest(
      title: '교보빌딩 앞 인도 <세종대로>',
      startTime: '15:00',
      endTime: '18:00',
      color: Colors.blue[100]!,
    ),
    // Protest(
    //   title: '교보빌딩 앞 인도 <세종대로>',
    //   startTime: '19:00',
    //   endTime: '23:00',
    //   color: Colors.blue[100]!,
    // ),
  ];

  ProtestInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // CalendarEventData 리스트로 변환

    return Scaffold(
      appBar: AppBar(title: const Text('서울시 시위 일정')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 기존의 지도, 달력, 드롭다운 위젯들...

          // DayView 위젯으로 타임테이블 표시
          Expanded(child: HorizontalTimeTable(protests: protests)),

          // Expanded(
          //   child: DayView(
          //     controller: EventController()..addAll(events),
          //     startHour: 9,
          //     endHour: 18,
          //     showVerticalLine: true,
          //     timeLineWidth: 60,
          //     timeLineBuilder: (date) {
          //       return Container(
          //         padding: const EdgeInsets.all(8),
          //         child: Text(
          //           '${date.hour.toString().padLeft(2, '0')}:00',
          //           style: const TextStyle(fontSize: 14),
          //         ),
          //       );
          //     },
          //     eventTileBuilder: (date, events, boundary, start, end) {
          //       return Container(
          //         decoration: BoxDecoration(
          //           color: events[0].color,
          //           borderRadius: BorderRadius.circular(4),
          //         ),
          //         padding: const EdgeInsets.all(8),
          //         child: Text(
          //           events[0].title,
          //           style: const TextStyle(
          //             color: Colors.white,
          //             fontSize: 14,
          //           ),
          //           overflow: TextOverflow.ellipsis,
          //         ),
          //       );
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }

  (int, int) _parseTime(String time) {
    final parts = time.split(':');
    return (int.parse(parts[0]), int.parse(parts[1]));
  }

  double _calculateTopPosition(String startTime) {
    final startHour = int.parse(startTime.split(':')[0]);
    final startMinute = int.parse(startTime.split(':')[1]);
    return (startHour - 9) * 60.0 + startMinute;
  }

  double _calculateProtestDuration(String startTime, String endTime) {
    final startHour = int.parse(startTime.split(':')[0]);
    final startMinute = int.parse(startTime.split(':')[1]);
    final endHour = int.parse(endTime.split(':')[0]);
    final endMinute = int.parse(endTime.split(':')[1]);
    return (endHour - startHour) * 60.0 + (endMinute - startMinute);
  }
}

class Protest {
  final String title;
  final String startTime;
  final String endTime;
  final Color color;

  Protest({
    required this.title,
    required this.startTime,
    required this.endTime,
    required this.color,
  });
}
