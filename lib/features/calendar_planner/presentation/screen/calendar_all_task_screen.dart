// calendar_all_task_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/calendar_task_model.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/provider/calendar_task_provider.dart';
import 'package:abeul_planner/core/utils/priority_icon.dart';

class CalendarAllTaskScreen extends ConsumerStatefulWidget {
  const CalendarAllTaskScreen({super.key});

  @override
  ConsumerState<CalendarAllTaskScreen> createState() => _CalendarAllTaskScreenState();
}

class _CalendarAllTaskScreenState extends ConsumerState<CalendarAllTaskScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(calendarTaskProvider);
    final now = DateTime.now();
    final pastTasks = tasks.where((task) => task.date.isBefore(DateTime(now.year, now.month, now.day))).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final upcomingTasks = tasks.where((task) => !task.date.isBefore(DateTime(now.year, now.month, now.day))).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Scaffold(
        appBar: CustomAppBar(
          title: Text('달력 플래너 일정 목록', style: AppTextStyles.title.copyWith(color: AppColors.text)),
          isTransparent: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.text),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.text,
                  unselectedLabelColor: AppColors.subText,
                  labelStyle: AppTextStyles.body,
                  unselectedLabelStyle: AppTextStyles.body,
                  indicator: BoxDecoration(
                    color: AppColors.highlight,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  indicatorPadding: EdgeInsets.all(4.w),
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(text: '지난 일정'),
                    Tab(text: '다가오는 일정'),
                  ],
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  dividerColor: Colors.transparent,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTaskList(pastTasks),
                    _buildTaskList(upcomingTasks),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(List<CalendarTaskModel> tasks) {
    if (tasks.isEmpty) {
      return const Center(child: Text('등록된 일정이 없습니다.'));
    }
    return ListView.separated(
      itemCount: tasks.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primary, width: 1.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4.r,
                offset: Offset(0, 2.h),
              )
            ],
          ),
          child: Row(
            children: [
              getPriorityIcon(task.priority),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('yyyy.MM.dd').format(task.date),
                      style: AppTextStyles.caption,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      task.memo,
                      style: AppTextStyles.body.copyWith(
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        color: task.isCompleted ? AppColors.subText : AppColors.text,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 24.w,
                height: 24.w,
                child: Checkbox(
                  value: task.isCompleted,
                  onChanged: (_) {
                    ref.read(calendarTaskProvider.notifier).toggleTask(task);
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
