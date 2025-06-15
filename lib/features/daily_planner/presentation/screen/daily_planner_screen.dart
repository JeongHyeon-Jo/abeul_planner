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
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/onboarding/onboarding_mixin.dart';
import 'package:abeul_planner/core/onboarding/onboarding_overlay.dart';
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

class _DailyPlannerScreenState extends ConsumerState<DailyPlannerScreen> with OnboardingMixin {
  final TextEditingController _situationController = TextEditingController(); // 상황 입력
  final TextEditingController _actionController = TextEditingController(); // 행동 입력
  final appBarTitle = DateFormat('yyyy년 M월 d일 (E)', 'ko_KR').format(DateTime.now());
  bool _isEditing = false; // 편집 모드 여부

  // 온보딩을 위한 GlobalKey들
  final GlobalKey _editButtonKey = GlobalKey();
  final GlobalKey _fabKey = GlobalKey();

  @override
  String get onboardingKey => 'daily';

  @override
  List<OnboardingStep> get onboardingSteps => [
    OnboardingStep(
      title: '일정 추가하기',
      description: '우측 하단의 + 버튼을 눌러\n새로운 일상 일정을 추가할 수 있습니다.\n언제, 어떤 행동을 할지 미리 계획해보세요!',
      targetKey: _fabKey,
    ),
    OnboardingStep(
      title: '편집 모드',
      description: '우측 상단의 편집 버튼을 눌러\n일정을 수정, 삭제가 가능합니다.\n일정의 순서를 바꿀 수도 있습니다!',
      targetKey: _editButtonKey,
    ),
    const OnboardingStep(
      title: '일상 플래너 완료!',
      description: '이제 언제 어떤 행동을 할지\n미리 계획하고 관리할 수 있습니다.\n상황별 행동 계획을 세워\n더 체계적인 일상을 만들어보세요!',
    ),
  ];

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

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(dailyTaskProvider);
    final user = ref.watch(userProvider);

    // 편집 모드일 때는 순서 유지, 아닐 때는 유저 설정에 따라 정렬
    final sortedTasks = _isEditing || !user.autoSortCompleted
        ? tasks
        : [
            ...tasks.where((task) => !task.isCompleted),
            ...tasks.where((task) => task.isCompleted),
          ];

    final mainContent = Scaffold(
      appBar: CustomAppBar(
        title: Text(
          appBarTitle,
          style: AppTextStyles.title.copyWith(color: AppColors.text),
        ),
        isTransparent: true,
        actions: [
          IconButton(
            key: _editButtonKey,
            icon: Icon(
              _isEditing ? Icons.check : Icons.edit_calendar,
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
                        scrollController: scrollController,
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
          key: _fabKey,
          onPressed: () => _showTaskDialog(),
          backgroundColor: AppColors.accent,
          child: Icon(Icons.add, size: 24.sp),
        ),
      ),
    );

    return buildWithOnboarding(mainContent);
  }
}