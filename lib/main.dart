import 'package:flutter/material.dart';
import 'package:seoul_map_flutter/combined_screen.dart';
import 'package:seoul_map_flutter/time_table.dart';
import 'seoul_map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MainNavi(),
        '/seoul': (context) => const SeoulMap(),
        '/time': (context) => ProtestInfoScreen(),
        '/combined': (context) => const CombinedScreen()
      },
    );
  }
}

class MainNavi extends StatelessWidget {
  const MainNavi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: () {
                Navigator.pushNamed(context, '/seoul');
              },
              child: const Text('seoul'),
            ),
            const SizedBox(
              height: 10,
            ),
            FilledButton(
              onPressed: () {
                Navigator.pushNamed(context, '/time');
              },
              child: const Text('time_table'),
            ),
            const SizedBox(
              height: 10,
            ),
            FilledButton(
              onPressed: () {
                Navigator.pushNamed(context, '/combined');
              },
              child: const Text('combined'),
            ),
          ],
        ),
      ),
    );
  }
}
