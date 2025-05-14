// calendar_record_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/calendar_task_model.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/provider/calendar_task_provider.dart';

class CalendarRecordScreen extends ConsumerStatefulWidget {
  const CalendarRecordScreen({super.key});

  @override
  ConsumerState<CalendarRecordScreen> createState() => _CalendarRecordScreenState();
}

class _CalendarRecordScreenState extends ConsumerState<CalendarRecordScreen> {
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    final calendarList = ref.watch(calendarTaskProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('달력 플래너 기록', style: AppTextStyles.title.copyWith(color: AppColors.text)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit, color: AppColors.text),
            onPressed: () => setState(() => isEditing = !isEditing),
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            onPressed: () => ref.read(calendarTaskProvider.notifier).deleteAll(),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: calendarList.isEmpty
            ? const Center(child: Text('기록이 없습니다'))
            : ListView.separated(
                itemCount: calendarList.length,
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final task = calendarList[index];
                  return ListTile(
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      side: BorderSide(color: AppColors.borderColor),
                    ),
                    leading: Icon(
                      task.priority == '중요' ? Icons.priority_high : Icons.radio_button_unchecked,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      '${DateFormat('yyyy.MM.dd').format(task.date)}: ${task.memo}',
                      style: AppTextStyles.body,
                    ),
                    trailing: isEditing
                        ? IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => ref.read(calendarTaskProvider.notifier).deleteSpecificTask(task),
                          )
                        : null,
                  );
                },
              ),
      ),
    );
  }
}
