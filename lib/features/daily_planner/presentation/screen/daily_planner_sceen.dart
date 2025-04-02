import 'package:flutter/material.dart';

class DailyPlannerScreen extends StatefulWidget {
  const DailyPlannerScreen({super.key});

  @override
  State<DailyPlannerScreen> createState() => _DailyPlannerScreenState();
}

class _DailyPlannerScreenState extends State<DailyPlannerScreen> {
  final TextEditingController _situationController = TextEditingController();
  final TextEditingController _actionController = TextEditingController();

  final List<String> _dailyPlans = [];

  void _addPlan() {
    final situation = _situationController.text.trim();
    final action = _actionController.text.trim();

    if (situation.isNotEmpty && action.isNotEmpty) {
      setState(() {
        _dailyPlans.add('[$situation] → $action');
        _situationController.clear();
        _actionController.clear();
      });
    }
  }

  @override
  void dispose() {
    _situationController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일상 플래너'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 상황 + 행동 입력 필드
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _situationController,
                    decoration: const InputDecoration(
                      labelText: '상황 (예: 출근하면)',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _actionController,
                    decoration: const InputDecoration(
                      labelText: '행동 (예: 스트레칭하기)',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _addPlan,
                  icon: const Icon(Icons.add_circle),
                  color: Colors.blue,
                )
              ],
            ),
            const SizedBox(height: 16),
            // 약속 리스트
            Expanded(
              child: _dailyPlans.isEmpty
                  ? const Center(child: Text('아직 등록된 약속이 없어요.'))
                  : ListView.builder(
                      itemCount: _dailyPlans.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.check_circle_outline),
                          title: Text(_dailyPlans[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
