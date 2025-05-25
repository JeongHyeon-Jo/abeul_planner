import 'package:abeul_planner/features/calendar_planner/presentation/widget/calendar_task_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/calendar_task_model.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/provider/calendar_task_provider.dart';

class SearchTaskScreen extends ConsumerStatefulWidget {
  const SearchTaskScreen({super.key});

  @override
  ConsumerState<SearchTaskScreen> createState() => _SearchTaskScreenState();
}

class _SearchTaskScreenState extends ConsumerState<SearchTaskScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final allTasks = ref.watch(calendarTaskProvider);
    final now = DateTime.now();

    final matched = allTasks
        .where((task) => task.memo.contains(_query))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final before = matched.where((t) => t.date.isBefore(now)).toList();
    final after = matched.where((t) => !t.date.isBefore(now)).toList();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.h),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.text),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: TextField(
                    autofocus: true,
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      hintText: '일정 검색',
                      hintStyle: AppTextStyles.body.copyWith(color: AppColors.subText),
                      isDense: true,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                    style: AppTextStyles.title.copyWith(fontSize: 18.sp),
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _query.isEmpty
          ? const Center(child: Text('검색어를 입력하세요'))
          : ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              children: [
                if (before.isNotEmpty)
                ...before.map(_buildItem),
              ],
            ),
    );
  }

  Widget _buildItem(CalendarTaskModel task) => InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => CalendarTaskDialog(
            existingTask: task,
            selectedDate: task.date,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('yyyy년 M월 d일 (E)', 'ko_KR').format(task.date),
                    style: AppTextStyles.caption,
                  ),
                  SizedBox(height: 4.h),
                  Text(task.memo, style: AppTextStyles.body),
                ],
              ),
            ),
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: Checkbox(
                value: task.isCompleted,
                onChanged: null,
              ),
            ),
          ],
        ),
      ),
    );
}
