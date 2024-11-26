import 'package:flutter/material.dart';
import 'package:seoul_map_flutter/seoul_map.dart';
import 'package:seoul_map_flutter/time_table.dart';

class CombinedScreen extends StatelessWidget {
  const CombinedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('서울시 시위 일정'),
            floating: true,
            snap: true,
            // centerTitle: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const MapSection(),
                const Text('gg'),
                ProtestInfoScreen(),
              ]),
            ),
          ),
        ],
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: SizedBox(
      //   width: 100,
      //   height: 48,
      //   child: FloatingActionButton.extended(
      //     elevation: 4,
      //     backgroundColor: Colors.blue,
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(16),
      //     ),
      //     onPressed: () {
      //       // 버튼 동작
      //     },
      //     label: const Text(
      //       '전체',
      //       style: TextStyle(
      //         color: Colors.white,
      //         fontSize: 16,
      //         fontWeight: FontWeight.bold,
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}

class MapSection extends StatelessWidget {
  const MapSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: SeoulMap(),
        ),
      ],
    );
  }
}
