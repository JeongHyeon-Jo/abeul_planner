// daily_planner_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/features/daily_planner/data/model/daily_task_model.dart';
import 'package:abeul_planner/features/daily_planner/presentation/provider/daily_task_provider.dart';
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/core/color.dart';
import 'package:abeul_planner/core/text_styles.dart';

class DailyPlannerScreen extends ConsumerStatefulWidget {
  const DailyPlannerScreen({super.key});

  @override
  ConsumerState<DailyPlannerScreen> createState() => _DailyPlannerScreenState();
}

class _DailyPlannerScreenState extends ConsumerState<DailyPlannerScreen> {
  final TextEditingController _situationController = TextEditingController();
  final TextEditingController _actionController = TextEditingController();
  String _selectedPriority = '보통';
  bool _isEditing = false;
  int? _editingIndex;

  final List<String> _priorityKeys = ['낮음', '보통', '중요'];

  Icon _getPriorityIcon(String priority) {
    switch (priority) {
      case '중요':
        return Icon(Icons.priority_high, color: Colors.red, size: 20.sp);
      case '보통':
        return Icon(Icons.circle, color: Colors.orange, size: 14.sp);
      case '낮음':
      default:
        return Icon(Icons.arrow_downward, color: Colors.grey, size: 14.sp);
    }
  }

  /// 할 일 추가 또는 수정 다이얼로그
  void _showTaskDialog({DailyTaskModel? task, int? index}) {
    if (task != null) {
      _situationController.text = task.situation;
      _actionController.text = task.action;
      _selectedPriority = task.priority;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(task == null ? '새 플랜 추가' : '플랜 수정', style: AppTextStyles.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _situationController,
                decoration: const InputDecoration(labelText: '상황 (예: 출근하면)'),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _actionController,
                decoration: const InputDecoration(labelText: '행동 (예: 스트레칭하기)'),
              ),
              SizedBox(height: 8.h),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                items: _priorityKeys.map((level) => DropdownMenuItem(
                  value: level,
                  child: Row(
                    children: [
                      _getPriorityIcon(level),
                      SizedBox(width: 8.w),
                      Text(level, style: AppTextStyles.body),
                    ],
                  ),
                )).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedPriority = value);
                },
                decoration: const InputDecoration(labelText: '중요도'),
              ),
              if (task != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showDeleteDialog(index!);
                    },
                    child: Text('플랜 제거', style: AppTextStyles.caption.copyWith(color: Colors.red)),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _situationController.clear();
                _actionController.clear();
                Navigator.of(context).pop();
              },
              child: Text('취소', style: AppTextStyles.body.copyWith(color: AppColors.subText)),
            ),
            ElevatedButton(
              onPressed: () {
                final situation = _situationController.text.trim();
                final action = _actionController.text.trim();

                if (situation.isEmpty || action.isEmpty) return;

                final newTask = DailyTaskModel(
                  situation: situation,
                  action: action,
                  isCompleted: task?.isCompleted ?? false,
                  priority: _selectedPriority,
                );

                if (task == null) {
                  ref.read(dailyTaskProvider.notifier).addTask(newTask);
                } else {
                  ref.read(dailyTaskProvider.notifier).editTask(index!, newTask);
                }

                _situationController.clear();
                _actionController.clear();
                Navigator.of(context).pop();
              },
              child: Text('저장', style: AppTextStyles.button),
            ),
          ],
        );
      },
    );
  }

  /// 플랜 제거 확인 다이얼로그
  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('플랜 제거', style: AppTextStyles.title),
          content: Text('정말 이 플랜을 제거하시겠습니까?', style: AppTextStyles.body),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('취소', style: AppTextStyles.body.copyWith(color: AppColors.subText)),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(dailyTaskProvider.notifier).removeTask(index);
                Navigator.of(context).pop();
              },
              child: Text('제거', style: AppTextStyles.button),
            ),
          ],
        );
      },
    );
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
      appBar: CustomAppBar(
        title: '',
        isTransparent: true,
        actions: [
          TextButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            child: Text(
              _isEditing ? '완료' : '편집',
              style: AppTextStyles.body.copyWith(color: AppColors.text),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0.w),
          child: Column(
            children: [
              Expanded(
                child: tasks.isEmpty
                    ? Center(child: Text('아직 등록된 약속이 없어요.', style: AppTextStyles.body))
                    : ReorderableListView.builder(
                        itemCount: tasks.length,
                        onReorder: (oldIndex, newIndex) {
                          // TODO: 순서 변경 로직 추가 필요
                        },
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Container(
                            key: ValueKey('$index-${task.situation}'),
                            margin: EdgeInsets.symmetric(vertical: 6.h),
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: AppColors.divider),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                _getPriorityIcon(task.priority),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(task.situation, style: AppTextStyles.body),
                                      SizedBox(height: 4.h),
                                      Text(task.action, style: AppTextStyles.caption),
                                    ],
                                  ),
                                ),
                                if (_isEditing) ...[
                                  IconButton(
                                    icon: Icon(Icons.edit, color: AppColors.subText),
                                    onPressed: () => _showTaskDialog(task: task, index: index),
                                  ),
                                  const Icon(Icons.drag_indicator),
                                ] else
                                  Checkbox(
                                    value: task.isCompleted,
                                    onChanged: (_) {
                                      ref.read(dailyTaskProvider.notifier).toggleTask(index);
                                    },
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
