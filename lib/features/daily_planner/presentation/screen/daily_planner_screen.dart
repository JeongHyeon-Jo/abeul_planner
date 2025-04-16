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

/// 중요도에 따른 아이콘 반환 함수
Widget _getPriorityIcon(String priority) {
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

/// 일상 플래너 메인 화면
class DailyPlannerScreen extends ConsumerStatefulWidget {
  const DailyPlannerScreen({super.key});

  @override
  ConsumerState<DailyPlannerScreen> createState() => _DailyPlannerScreenState();
}

class _DailyPlannerScreenState extends ConsumerState<DailyPlannerScreen> {
  final TextEditingController _situationController = TextEditingController(); // 상황 입력 컨트롤러
  final TextEditingController _actionController = TextEditingController(); // 행동 입력 컨트롤러
  String _selectedPriority = '보통'; // 선택된 중요도 기본값
  String _filterPriority = '전체'; // 필터링할 중요도 (전체, 낮음, 보통, 중요)
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

  // 중요도 필터 선택 모달 표시
  void _showPriorityFilterDialog() {
    final priorities = ['낮음', '보통', '중요'];
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: priorities.map((priority) {
            return ListTile(
              leading: _getPriorityIcon(priority), // 중요도 아이콘 표시
              title: Text('중요도: $priority'), // 리스트에서 선택 가능한 중요도 항목
              onTap: () {
                setState(() => _filterPriority = priority); // 선택 시 필터 적용
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
    final tasks = ref.watch(dailyTaskProvider); // 전체 할 일 목록 가져오기

    // 중요도 필터링 적용
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
            ? Text('', style: AppTextStyles.title) // 전체일 경우 타이틀 없음
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _getPriorityIcon(_filterPriority), // 현재 필터 아이콘 표시
                  SizedBox(width: 6.w),
                  Text(
                    '중요도: $_filterPriority', // 현재 필터 상태 표시
                    style: AppTextStyles.title.copyWith(color: AppColors.text),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => setState(() => _filterPriority = '전체'), // 필터 해제
                    child: Icon(
                      Icons.close,
                      size: 20.sp,
                      color: AppColors.subText,
                    ),
                  ),
                ],
              ),
        isTransparent: true,
        leading: IconButton(
          icon: Icon(
            Icons.filter_list,
            color: AppColors.text,
            size: 27.sp,
          ),
          onPressed: _showPriorityFilterDialog, // 필터 버튼
          tooltip: '중요도 필터',
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.check : Icons.edit, // 편집 모드 전환 버튼
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
              if (_isEditing)
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Center(
                    child: Text(
                      '플랜을 길게 눌러 순서를 변경해 보세요.', // 편집 안내 문구
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.subText,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: sortedTasks.isEmpty
                    ? Center(child: Text('아직 등록된 약속이 없어요.', style: AppTextStyles.body)) // 할 일 없음 안내
                    : ReorderableListView.builder(
                        itemCount: sortedTasks.length,
                        onReorder: (oldIndex, newIndex) {
                          ref.read(dailyTaskProvider.notifier).reorderTask(oldIndex, newIndex); // 순서 변경
                        },
                        itemBuilder: (context, index) => TaskTile(
                          key: ValueKey('$index-${sortedTasks[index].situation}'), // 키 설정
                          task: sortedTasks[index],
                          index: index,
                          isEditing: _isEditing,
                          onEdit: () => _showTaskDialog(task: sortedTasks[index], index: index), // 편집
                          onToggle: () => ref.read(dailyTaskProvider.notifier).toggleTask(
                                tasks.indexOf(sortedTasks[index]), // 체크박스 토글
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
        onPressed: () => _showTaskDialog(), // 할 일 추가
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
