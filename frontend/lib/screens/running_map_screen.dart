import 'package:flutter/material.dart';

import '../widgets/app_cards.dart';

class RunningMapScreen extends StatelessWidget {
  const RunningMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('러닝 지도')),
      body: const Padding(
        padding: EdgeInsets.all(22),
        child: MapPreview(height: 260, label: '실시간 위치 지도'),
      ),
    );
  }
}
