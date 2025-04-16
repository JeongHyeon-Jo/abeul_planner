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
  final TextEditingController _situationController = TextEditingController(); // 상황 입력 컨트롤러
  final TextEditingController _actionController = TextEditingController(); // 행동 입력 컨트롤러
  String _selectedPriority = '보통'; // 선택된 중요도 기본값
  bool _isEditing = false; // 편집 모드 여부
  int? _editingIndex; // 편집 중인 인덱스

  @override
  void dispose() {
    _situationController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  // 플랜 추가 및 수정 다이얼로그 표시
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

  // 삭제 확인 다이얼로그 표시
  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => DeleteDialog(index: index),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(dailyTaskProvider); // 전체 플랜 상태 가져오기

    // 완료 여부에 따라 정렬: 미완료 → 완료
    final sortedTasks = [
      ...tasks.where((task) => !task.isCompleted),
      ...tasks.where((task) => task.isCompleted),
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: '',
        isTransparent: true,
        actions: [
          // 편집 모드 토글 버튼
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
              // 편집 모드일 때 안내 문구
              if (_isEditing)
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Center(
                    child: Text(
                      '플랜을 길게 눌러 순서를 변경해 보세요.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.subText,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: sortedTasks.isEmpty
                    ? Center(child: Text('아직 등록된 약속이 없어요.', style: AppTextStyles.body))
                    : ReorderableListView.builder(
                        itemCount: sortedTasks.length,
                        onReorder: (oldIndex, newIndex) {
                          // 순서 변경 처리
                          ref.read(dailyTaskProvider.notifier).reorderTask(oldIndex, newIndex);
                        },
                        itemBuilder: (context, index) => TaskTile(
                          key: ValueKey('$index-${sortedTasks[index].situation}'),
                          task: sortedTasks[index],
                          index: index,
                          isEditing: _isEditing,
                          onEdit: () => _showTaskDialog(task: sortedTasks[index], index: index),
                          onToggle: () => ref.read(dailyTaskProvider.notifier).toggleTask(
                                tasks.indexOf(sortedTasks[index]), // 실제 인덱스 기준으로 toggle
                              ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      // 플랜 추가 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(),
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
