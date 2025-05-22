// daily_record_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:abeul_planner/features/settings/data/datasource/record/daily_record_box.dart';
// core
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';

class DailyRecordScreen extends ConsumerStatefulWidget {
  const DailyRecordScreen({super.key});

  @override
  ConsumerState<DailyRecordScreen> createState() => _DailyRecordScreenState();
}

class _DailyRecordScreenState extends ConsumerState<DailyRecordScreen> {
  bool isEditing = false;
  DateTime? expandedDate;

  @override
  Widget build(BuildContext context) {
    final recordBox = DailyRecordBox.box;
    final records = recordBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: CustomAppBar(
        title: Text('일상 플래너 기록', style: AppTextStyles.title.copyWith(color: AppColors.text)),
        isTransparent: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit, color: AppColors.text),
            onPressed: () => setState(() => isEditing = !isEditing),
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            onPressed: () {
              DailyRecordBox.box.clear();
              setState(() {});
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: records.isEmpty
            ? const Center(child: Text('기록이 없습니다'))
            : ListView.separated(
                itemCount: records.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final record = records[index];
                  final isExpanded = expandedDate == record.date;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            expandedDate = isExpanded ? null : record.date;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.borderColor),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('yyyy.MM.dd').format(record.date),
                                style: AppTextStyles.title,
                              ),
                              Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                            ],
                          ),
                        ),
                      ),
                      if (isExpanded)
                        ...record.tasks.map(
                          (task) => Padding(
                            padding: EdgeInsets.only(left: 12.w, top: 8.h),
                            child: Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      '${task.situation} → ${task.action}',
                                      style: AppTextStyles.body,
                                    ),
                                  ),
                                  if (isEditing)
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.red),
                                      onPressed: () {
                                        record.tasks.remove(task);
                                        DailyRecordBox.box.putAt(index, record);
                                        setState(() {});
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
