// daily_record_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/features/daily_planner/presentation/provider/daily_task_provider.dart';
import 'package:abeul_planner/features/daily_planner/data/model/daily_task_model.dart';

class DailyRecordScreen extends ConsumerStatefulWidget {
  const DailyRecordScreen({super.key});

  @override
  ConsumerState<DailyRecordScreen> createState() => _DailyRecordScreenState();
}

class _DailyRecordScreenState extends ConsumerState<DailyRecordScreen> {
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    final dailyList = ref.watch(dailyTaskProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('일상 플래너 기록', style: AppTextStyles.title.copyWith(color: AppColors.text)),
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
            onPressed: () => ref.read(dailyTaskProvider.notifier).deleteAll(),
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: dailyList.isEmpty
            ? const Center(child: Text('기록이 없습니다'))
            : ListView.separated(
                itemCount: dailyList.length,
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final task = dailyList[index];
                  return ListTile(
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      side: BorderSide(color: AppColors.borderColor),
                    ),
                    leading: Icon(
                      task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: AppColors.primary,
                    ),
                    title: Text('${task.situation} → ${task.action}', style: AppTextStyles.body),
                    trailing: isEditing
                        ? IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => ref.read(dailyTaskProvider.notifier).deleteAt(index),
                          )
                        : null,
                  );
                },
              ),
      ),
    );
  }
}
