// daily_planner_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/features/daily_planner/data/model/daily_task_model.dart';
import 'package:abeul_planner/features/daily_planner/presentation/provider/daily_task_provider.dart';
import 'package:abeul_planner/features/auth/presentation/provider/user_provider.dart';
// core
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/core/utils/priority_icon.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
// widget
import 'package:abeul_planner/features/daily_planner/presentation/widget/daily_task_tile.dart';
import 'package:abeul_planner/features/daily_planner/presentation/widget/daily_task_dialog.dart';
import 'package:abeul_planner/features/daily_planner/presentation/widget/daily_delete_dialog.dart';

// 일상 플래너 메인 화면
class DailyPlannerScreen extends ConsumerStatefulWidget {
  const DailyPlannerScreen({super.key});

  @override
  ConsumerState<DailyPlannerScreen> createState() => _DailyPlannerScreenState();
}

class _DailyPlannerScreenState extends ConsumerState<DailyPlannerScreen> {
  final TextEditingController _situationController = TextEditingController(); // 상황 입력
  final TextEditingController _actionController = TextEditingController(); // 행동 입력
  final appBarTitle = DateFormat('yyyy년 M월 d일 (E)', 'ko_KR').format(DateTime.now());
  String _filterPriority = '전체'; // // 중요도 필터 값 ('전체', '낮음', '보통', '중요')
  bool _isEditing = false; // 편집 모드 여부

  @override
  void dispose() {
    _situationController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  // 플랜 추가 또는 수정 다이얼로그 호출 함수
  void _showTaskDialog({DailyTaskModel? task, int? index}) {
    String selectedPriority = task?.priority ?? '보통';

    if (task != null) {
      _situationController.text = task.situation;
      _actionController.text = task.action;
    } else {
      _situationController.clear();
      _actionController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => DailyTaskDialog(
        task: task,
        index: index,
        situationController: _situationController,
        actionController: _actionController,
        selectedPriority: selectedPriority,
        onDelete: (idx) => _showDeleteDialog(idx),
      ),
    );
  }

  // 삭제 다이얼로그 호출 함수
  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => DailyDeleteDialog(index: index),
    );
  }

  // 중요도 필터 다이얼로그 표시 함수
  void _showPriorityFilterDialog() {
    final priorities = ['전체', '낮음', '보통', '중요'];
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: priorities.map((priority) {
            return ListTile(
              leading: priority == '전체'
                  ? const Icon(Icons.close, color: AppColors.subText)
                  : getPriorityIcon(priority),
              title: Text(priority == '전체' ? '전체 보기' : '중요도: $priority'),
              onTap: () {
                setState(() => _filterPriority = priority);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(dailyTaskProvider);
    final user = ref.watch(userProvider);

    // 필터된 일정 목록
    final filteredTasks = _filterPriority == '전체'
        ? tasks
        : tasks.where((task) => task.priority == _filterPriority).toList();

    // 편집 모드일 때는 순서 유지, 아닐 때는 유저 설정에 따라 정렬
    final sortedTasks = _isEditing || !user.autoSortCompleted
        ? filteredTasks
        : [
            ...filteredTasks.where((task) => !task.isCompleted),
            ...filteredTasks.where((task) => task.isCompleted),
          ];

    return Scaffold(
      appBar: CustomAppBar(
        title: _filterPriority == '전체'
            ? Text(
                appBarTitle,
                style: AppTextStyles.title.copyWith(color: AppColors.text),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  getPriorityIcon(_filterPriority),
                  SizedBox(width: 6.w),
                  Text('중요도: $_filterPriority', style: AppTextStyles.title.copyWith(color: AppColors.text)),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => setState(() => _filterPriority = '전체'),
                    child: Icon(Icons.close, size: 20.sp, color: AppColors.subText),
                  ),
                ],
              ),
        isTransparent: true,
        leading: IconButton(
          icon: Icon(Icons.filter_list, color: AppColors.text, size: 27.sp),
          onPressed: _showPriorityFilterDialog,
          tooltip: '중요도 필터',
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.check : Icons.edit,
              color: _isEditing ? AppColors.success : AppColors.text,
              size: 27.sp,
            ),
            onPressed: () => setState(() => _isEditing = !_isEditing),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: sortedTasks.isEmpty
                    ? Center(child: Text('등록된 일정이 없습니다.', style: AppTextStyles.body))
                    : ReorderableListView.builder(
                        padding: EdgeInsets.only(bottom: 80.h),
                        buildDefaultDragHandles: false,
                        itemCount: sortedTasks.length,
                        onReorder: (oldIndex, newIndex) {
                          ref.read(dailyTaskProvider.notifier).reorderTask(oldIndex, newIndex);
                        },
                        itemBuilder: (context, index) {
                          final task = sortedTasks[index];
                          return DailyTaskTile(
                            key: ValueKey('$index-${task.situation}'),
                            task: task,
                            index: index,
                            isEditing: _isEditing,
                            onEdit: () => _showTaskDialog(task: task, index: index),
                            onToggle: () => ref.read(dailyTaskProvider.notifier).toggleTask(
                                  tasks.indexOf(task),
                                ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      // 일정 추가 버튼
      floatingActionButton: Transform.translate(
        offset: Offset(-6.w, -6.h),
        child: FloatingActionButton(
          onPressed: () => _showTaskDialog(),
          backgroundColor: AppColors.accent,
          child: Icon(Icons.add, size: 24.sp),
        ),
      ),
    );
  }
}
