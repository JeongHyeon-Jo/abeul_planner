import 'package:flutter/material.dart';

class WeeklyTabContent extends StatelessWidget {
  final String day;

  const WeeklyTabContent({super.key, required this.day});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$day요일의 컨셉 계획이 여기에 표시됩니다.',
        style: const TextStyle(fontSize: 18),
        textAlign: TextAlign.center,
      ),
    );
  }
}
