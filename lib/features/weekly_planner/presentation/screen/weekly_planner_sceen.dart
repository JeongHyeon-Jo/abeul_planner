// weekly_planner_screen.dart
import 'package:flutter/material.dart';
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/core/text_styles.dart';
import 'package:abeul_planner/core/color.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/widget/weekly_tab_content.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/widget/weekly_task_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abeul_planner/core/widgets/priority_icon.dart';

/// 주간 플래너 메인 화면
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
  bool _isEditing = false;
  String _filterPriority = '전체';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: days.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => WeeklyTaskDialog(
        days: days,
        onTaskAdded: (selectedDay) {
          setState(() {
            _tabController.index = days.indexOf(selectedDay);
          });
        },
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
    return DefaultTabController(
      length: days.length,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight + 48.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomAppBar(
                title: _filterPriority == '전체'
                    ? Text('', style: AppTextStyles.title)
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4.r,
                        offset: Offset(0, 2.h),
                      )
                    ],
                    border: Border.all(color: AppColors.primary, width: 1.w),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(width: 3.h, color: AppColors.highlight),
                      insets: EdgeInsets.symmetric(horizontal: 8.w),
                    ),
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: AppColors.text,
                    unselectedLabelColor: AppColors.subText,
                    labelStyle: AppTextStyles.body,
                    tabs: List.generate(days.length, (index) {
                      return Container(
                        alignment: Alignment.center,
                        child: Text(days[index], style: AppTextStyles.body),
                      );
                    }),
                    dividerColor: Colors.transparent,
                    indicatorPadding: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    labelPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddTaskDialog(context),
          backgroundColor: AppColors.accent,
          child: Icon(Icons.add, size: 24.sp),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                return WeeklyTabContent(
                  day: day,
                  isEditing: _isEditing,
                  filterPriority: _filterPriority,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
