// weekly_planner_screen.dart
import 'package:flutter/material.dart';
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/widget/weekly_task_dialog.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/widget/weekly_task_list.dart';
import 'package:abeul_planner/core/utils/priority_icon.dart';
import 'package:abeul_planner/features/weekly_planner/data/model/weekly_task_model.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/provider/weekly_task_provider.dart';

class WeeklyPlannerScreen extends ConsumerStatefulWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  ConsumerState<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends ConsumerState<WeeklyPlannerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final List<String> days = ['월', '화', '수', '목', '금', '토', '일'];
  final List<String> _priorities = ['전체', '낮음', '보통', '중요'];
  bool _isEditing = false; // 편집 모드 여부
  String _filterPriority = '전체'; // 필터링할 중요도

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final weekday = now.weekday;
    final todayIndex = (weekday - 1).clamp(0, 6); // 월(1) ~ 일(7) → 0~6 인덱스로 변환
    _tabController = TabController(length: days.length, vsync: this, initialIndex: todayIndex);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 일정 추가 다이얼로그
  void _showAddTaskDialog(BuildContext context) {
    final currentDay = days[_tabController.index];
    showDialog(
      context: context,
      builder: (context) => WeeklyTaskDialog(
        days: days,
        onTaskAdded: (selectedDay) {
          setState(() {
            _tabController.index = days.indexOf(selectedDay);
          });
        },
        editingDay: currentDay,
      ),
    );
  }

  /// 중요도 필터 다이얼로그
  void _showPriorityFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _priorities.map((priority) {
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
    final tabWidth = (MediaQuery.of(context).size.width - 32.w) / 7;

    return DefaultTabController(
      length: days.length,
      child: Scaffold(
        appBar: CustomAppBar(
          title: _filterPriority == '전체'
              ? Text('', style: AppTextStyles.title)
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    getPriorityIcon(_filterPriority),
                    SizedBox(width: 6.w),
                    Text('중요도: $_filterPriority',
                        style: AppTextStyles.title.copyWith(color: AppColors.text)),
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

        floatingActionButton: Transform.translate(
          offset: Offset(-6.w, -6.h),
          child: FloatingActionButton(
            onPressed: () => _showAddTaskDialog(context),
            backgroundColor: AppColors.accent,
            child: Icon(Icons.add, size: 24.sp),
          ),
        ),

        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            children: [
              // 요일 탭바 (Stack 구조로 구분선 끝까지)
              SizedBox(
                height: 48.h,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppColors.primary, width: 1.w),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4.r,
                            offset: Offset(0, 2.h),
                          )
                        ],
                      ),
                    ),
                    ...List.generate(6, (i) {
                      return Positioned(
                        left: tabWidth * (i + 1),
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 1.w,
                          color: AppColors.highlight,
                        ),
                      );
                    }),
                    TabBar(
                      controller: _tabController,
                      isScrollable: false,
                      indicator: const BoxDecoration(),
                      dividerColor: Colors.transparent,
                      labelPadding: EdgeInsets.zero,
                      tabs: List.generate(days.length, (index) {
                        final isSelected = _tabController.index == index;
                        return Center(
                          child: Text(
                            days[index],
                            style: AppTextStyles.body.copyWith(
                              color: isSelected ? AppColors.highlight : AppColors.text,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                    border: Border.all(color: AppColors.primary, width: 1.w),
                  ),
                  child: IndexedStack(
                    index: _tabController.index,
                    children: days.map((day) {
                      final weekTask = ref.watch(weeklyTaskProvider).firstWhere(
                          (t) => t.day == day,
                          orElse: () => WeeklyTaskModel(day: day, tasks: []));

                      final filteredTasks = _filterPriority == '전체'
                          ? weekTask.tasks
                          : weekTask.tasks
                              .where((task) => task.priority == _filterPriority)
                              .toList();

                      final displayTasks = _isEditing
                          ? filteredTasks
                          : [
                              ...filteredTasks.where((task) => !task.isCompleted),
                              ...filteredTasks.where((task) => task.isCompleted),
                            ];

                      return SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WeeklyTaskList(
                                day: day,
                                tasks: displayTasks,
                                isEditing: _isEditing,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}