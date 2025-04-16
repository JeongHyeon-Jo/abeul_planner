// daily_planner_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/features/daily_planner/data/model/daily_task_model.dart';
import 'package:abeul_planner/features/daily_planner/presentation/provider/daily_task_provider.dart';
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/core/color.dart';
import 'package:abeul_planner/core/text_styles.dart';
// 위젯
import 'package:abeul_planner/features/daily_planner/presentation/widget/task_tile.dart';
import 'package:abeul_planner/features/daily_planner/presentation/widget/task_dialog.dart';
import 'package:abeul_planner/features/daily_planner/presentation/widget/delete_dialog.dart';

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

  @override
  void dispose() {
    _situationController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  void _showTaskDialog({DailyTaskModel? task, int? index}) {
    showDialog(
      context: context,
      builder: (context) => TaskDialog(
        task: task,
        index: index,
        situationController: _situationController,
        actionController: _actionController,
        selectedPriority: _selectedPriority,
        onPriorityChanged: (value) => setState(() => _selectedPriority = value),
        onDelete: (idx) => _showDeleteDialog(idx),
      ),
    );
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => DeleteDialog(index: index),
    );
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isEditing)
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Center(
                    child: Text(
                      '드래그 해서 순서를 변경해 보세요.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.subText,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: tasks.isEmpty
                    ? Center(child: Text('아직 등록된 약속이 없어요.', style: AppTextStyles.body))
                    : ReorderableListView.builder(
                        itemCount: tasks.length,
                        onReorder: (oldIndex, newIndex) {
                          ref.read(dailyTaskProvider.notifier).reorderTask(oldIndex, newIndex);
                        },
                        itemBuilder: (context, index) => TaskTile(
                          key: ValueKey('$index-${tasks[index].situation}'),
                          task: tasks[index],
                          index: index,
                          isEditing: _isEditing,
                          onEdit: () => _showTaskDialog(task: tasks[index], index: index),
                          onToggle: () => ref.read(dailyTaskProvider.notifier).toggleTask(index),
                        ),
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
