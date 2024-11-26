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
      title: 'test test!!!!!',
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: HorizontalTimeTable(protests: protests),
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
