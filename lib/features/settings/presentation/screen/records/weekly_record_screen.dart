// weekly_record_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/features/weekly_planner/data/model/weekly_task_model.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/provider/weekly_task_provider.dart';

class WeeklyRecordScreen extends ConsumerStatefulWidget {
  const WeeklyRecordScreen({super.key});

  @override
  ConsumerState<WeeklyRecordScreen> createState() => _WeeklyRecordScreenState();
}

class _WeeklyRecordScreenState extends ConsumerState<WeeklyRecordScreen> {
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    final weeklyMap = ref.watch(weeklyTaskProvider);
    final allTasks = weeklyMap.entries.expand((e) => e.value.map((t) => (e.key, t))).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('주간 플래너 기록', style: AppTextStyles.title.copyWith(color: AppColors.text)),
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
            onPressed: () => ref.read(weeklyTaskProvider.notifier).deleteAll(),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: allTasks.isEmpty
            ? const Center(child: Text('기록이 없습니다'))
            : ListView.separated(
                itemCount: allTasks.length,
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final entry = allTasks[index];
                  final day = entry.$1;
                  final task = entry.$2;
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
                    title: Text('$day요일: ${task.content}', style: AppTextStyles.body),
                    trailing: isEditing
                        ? IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              final list = weeklyMap[day]!;
                              final idx = list.indexOf(task);
                              if (idx != -1) {
                                ref.read(weeklyTaskProvider.notifier).deleteTask(day, idx);
                              }
                            },
                          )
                        : null,
                  );
                },
              ),
      ),
    );
  }
}
