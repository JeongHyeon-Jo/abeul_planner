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
import 'package:intl/intl.dart';

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
  final appBarTitle = DateFormat('yyyy년 M월 d일 (E)', 'ko_KR').format(DateTime.now());
  bool _isEditing = false;
  String _filterPriority = '전체';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final weekday = now.weekday;
    final todayIndex = (weekday - 1).clamp(0, 6);
    _selectedIndex = todayIndex;
    _tabController = TabController(length: days.length, vsync: this, initialIndex: todayIndex);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
              ? Text(
                  appBarTitle,
                  style: AppTextStyles.title.copyWith(color: AppColors.text),
                )
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
                      onTap: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      isScrollable: false,
                      indicator: const BoxDecoration(),
                      dividerColor: Colors.transparent,
                      labelPadding: EdgeInsets.zero,
                      tabs: List.generate(days.length, (index) {
                        final isSelected = _selectedIndex == index;
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
                  child: TabBarView(
                    controller: _tabController,
                    children: days.map((day) {
                      final weekTask = ref.watch(weeklyTaskProvider).firstWhere(
                          (t) => t.day == day,
                          orElse: () => WeeklyTaskModel(day: day, tasks: []));

                      final filteredTasks = _filterPriority == '전체'
                          ? weekTask.tasks
                          : weekTask.tasks
                              .where((task) => task.priority == _filterPriority)
                              .toList();

                      return SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WeeklyTaskList(
                                day: day,
                                tasks: filteredTasks,
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
