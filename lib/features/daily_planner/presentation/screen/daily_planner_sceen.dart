// daily_planner_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abeul_planner/features/daily_planner/data/model/daily_task_model.dart';
import 'package:abeul_planner/features/daily_planner/presentation/provider/daily_task_provider.dart';

class DailyPlannerScreen extends ConsumerStatefulWidget {
  const DailyPlannerScreen({super.key});

  @override
  ConsumerState<DailyPlannerScreen> createState() => _DailyPlannerScreenState();
}

class _DailyPlannerScreenState extends ConsumerState<DailyPlannerScreen> {
  final TextEditingController _situationController = TextEditingController();
  final TextEditingController _actionController = TextEditingController();

  /// 새로운 할 일을 추가하는 함수
  void _addTask() {
    final situation = _situationController.text.trim();
    final action = _actionController.text.trim();

    if (situation.isNotEmpty && action.isNotEmpty) {
      final newTask = DailyTaskModel(
        situation: situation,
        action: action,
        isCompleted: false,
      );
      ref.read(dailyTaskProvider.notifier).addTask(newTask);
      _situationController.clear();
      _actionController.clear();
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
    final tasks = ref.watch(dailyTaskProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('일상 플래너'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// 상황 + 행동 입력 필드
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
                  onPressed: _addTask,
                  icon: const Icon(Icons.add_circle),
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),

            /// 할 일 리스트
            Expanded(
              child: tasks.isEmpty
                  ? const Center(child: Text('아직 등록된 약속이 없어요.'))
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return ListTile(
                          leading: Checkbox(
                            value: task.isCompleted,
                            onChanged: (_) {
                              ref.read(dailyTaskProvider.notifier).toggleTask(index);
                            },
                          ),
                          title: Text('🧩 ${task.situation} → ${task.action}'),
                          trailing: const Icon(Icons.drag_indicator),
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
