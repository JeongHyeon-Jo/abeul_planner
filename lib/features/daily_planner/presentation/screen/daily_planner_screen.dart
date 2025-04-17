// daily_planner_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/features/daily_planner/data/model/daily_task_model.dart';
import 'package:abeul_planner/features/daily_planner/presentation/provider/daily_task_provider.dart';
// core
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/core/widgets/priority_icon.dart';
import 'package:abeul_planner/core/color.dart';
import 'package:abeul_planner/core/text_styles.dart';
// 위젯
import 'package:abeul_planner/features/daily_planner/presentation/widget/task_tile.dart';
import 'package:abeul_planner/features/daily_planner/presentation/widget/task_dialog.dart';
import 'package:abeul_planner/features/daily_planner/presentation/widget/delete_dialog.dart';

/// 일상 플래너 메인 화면
class DailyPlannerScreen extends ConsumerStatefulWidget {
  const DailyPlannerScreen({super.key});

  @override
  ConsumerState<DailyPlannerScreen> createState() => _DailyPlannerScreenState();
}

class _DailyPlannerScreenState extends ConsumerState<DailyPlannerScreen> {
  final TextEditingController _situationController = TextEditingController(); // 상황 입력 컨트롤러
  final TextEditingController _actionController = TextEditingController(); // 행동 입력 컨트롤러
  String _filterPriority = '전체'; // 중요도 필터 값 ('전체', '낮음', '보통', '중요')
  bool _isEditing = false; // 편집 모드 여부
  int? _editingIndex; // 현재 편집 중인 인덱스

  @override
  void dispose() {
    _situationController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  /// 플랜 추가 또는 수정 다이얼로그 호출 함수
  void _showTaskDialog({DailyTaskModel? task, int? index}) {
    // 초기 선택된 중요도 값 설정 (기본값은 '보통')
    String selectedPriority = task?.priority ?? '보통';

    if (task != null) {
      // 수정인 경우 기존 값 입력
      _situationController.text = task.situation;
      _actionController.text = task.action;
    } else {
      // 추가인 경우 초기화
      _situationController.clear();
      _actionController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => TaskDialog(
        task: task,
        index: index,
        situationController: _situationController,
        actionController: _actionController,
        selectedPriority: selectedPriority,
        onDelete: (idx) => _showDeleteDialog(idx),
      ),
    );
  }

  /// 삭제 다이얼로그 호출 함수
  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => DeleteDialog(index: index),
    );
  }

  /// 중요도 필터 다이얼로그 표시 함수
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
                  ? const Icon(Icons.close, color: AppColors.subText) // 전체 보기용 아이콘
                  : getPriorityIcon(priority),
              title: Text(priority == '전체' ? '전체 보기' : '중요도: $priority'),
              onTap: () {
                setState(() => _filterPriority = priority); // 필터 적용
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
    final tasks = ref.watch(dailyTaskProvider); // 전체 플랜 목록

    // 필터링된 목록 생성
    final filteredTasks = _filterPriority == '전체'
        ? tasks
        : tasks.where((task) => task.priority == _filterPriority).toList();

    // 미완료 → 완료 순으로 정렬
    final sortedTasks = [
      ...filteredTasks.where((task) => !task.isCompleted),
      ...filteredTasks.where((task) => task.isCompleted),
    ];

    return Scaffold(
      appBar: CustomAppBar(
        title: _filterPriority == '전체'
            ? Text('', style: AppTextStyles.title)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  getPriorityIcon(_filterPriority), // 필터 아이콘
                  SizedBox(width: 6.w),
                  Text('중요도: $_filterPriority', style: AppTextStyles.title.copyWith(color: AppColors.text)),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => setState(() => _filterPriority = '전체'), // 필터 해제 (전체 보기)
                    child: Icon(Icons.close, size: 20.sp, color: AppColors.subText),
                  ),
                ],
              ),
        isTransparent: true, // 투명 앱바 여부
        leading: IconButton(
          icon: Icon(Icons.filter_list, color: AppColors.text, size: 27.sp),
          onPressed: _showPriorityFilterDialog, // 필터 버튼
          tooltip: '중요도 필터',
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit, color: _isEditing ? AppColors.success : AppColors.text, size: 27.sp),
            onPressed: () => setState(() => _isEditing = !_isEditing), // 편집 모드 전환
          ),
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
                    child: Text('일정을 길게 눌러 순서를 변경해 보세요.', style: AppTextStyles.caption.copyWith(color: AppColors.subText)),
                  ),
                ),
              Expanded(
                child: sortedTasks.isEmpty
                    ? Center(child: Text('아직 등록된 약속이 없어요.', style: AppTextStyles.body)) // 등록된 플랜이 없을 경우
                    : ReorderableListView.builder(
                        itemCount: sortedTasks.length,
                        onReorder: (oldIndex, newIndex) {
                          ref.read(dailyTaskProvider.notifier).reorderTask(oldIndex, newIndex); // 순서 변경 처리
                        },
                        itemBuilder: (context, index) => TaskTile(
                          key: ValueKey('$index-${sortedTasks[index].situation}'),
                          task: sortedTasks[index],
                          index: index,
                          isEditing: _isEditing,
                          onEdit: () => _showTaskDialog(task: sortedTasks[index], index: index), // 편집 다이얼로그
                          onToggle: () => ref.read(dailyTaskProvider.notifier).toggleTask(
                                tasks.indexOf(sortedTasks[index]),
                              ), // 체크박스 토글
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(), // 일정 추가 다이얼로그
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add),
      ),
    );
  }
}