// weekly_record_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/features/settings/data/datasource/record/weekly_record_box.dart';
import 'package:abeul_planner/features/weekly_planner/data/model/weekly_task_model.dart';
import 'package:abeul_planner/core/utils/priority_icon.dart';

class WeeklyRecordScreen extends ConsumerStatefulWidget {
  const WeeklyRecordScreen({super.key});

  @override
  ConsumerState<WeeklyRecordScreen> createState() => _WeeklyRecordScreenState();
}

class _WeeklyRecordScreenState extends ConsumerState<WeeklyRecordScreen> {
  bool isEditing = false;
  DateTime? expandedDate;

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('기록 삭제', style: AppTextStyles.title),
        content: Text(
          '정말로 모든 기록을 삭제하시겠습니까?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '아니오',
              style: AppTextStyles.body.copyWith(color: AppColors.text),
            ),
          ),
          TextButton(
            onPressed: () {
              WeeklyRecordBox.box.clear();
              setState(() {});
              Navigator.of(context).pop();
            },
            child: Text(
              '예',
              style: AppTextStyles.body.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recordBox = WeeklyRecordBox.box;
    final records = recordBox.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: CustomAppBar(
        title: Text('주간 플래너 기록', style: AppTextStyles.title.copyWith(color: AppColors.text)),
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.text),
            onSelected: (value) {
              if (value == 'delete_all') {
                _showDeleteConfirmationDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete_all',
                child: Text('모든 기록 삭제'),
              ),
            ],
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
                            border: Border.all(color: AppColors.primary),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${DateFormat('yyyy.MM.dd').format(record.date)} (${record.day})',
                                style: AppTextStyles.title,
                              ),
                              Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                            ],
                          ),
                        ),
                      ),
                      if (isExpanded)
                        ...record.tasks.map((WeeklyTask task) => Padding(
                          padding: EdgeInsets.only(left: 12.w, top: 8.h),
                          child: Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: AppColors.primary, width: 1.1.w),
                            ),
                            child: Row(
                              children: [
                                // 중요도 아이콘 왼쪽
                                getPriorityIcon(task.priority),
                                SizedBox(width: 8.w),

                                // 메모 본문 중앙
                                Expanded(
                                  child: Text(task.content, style: AppTextStyles.body),
                                ),

                                // 완료 여부 아이콘 오른쪽
                                Icon(
                                  task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                                  color: AppColors.primary,
                                ),

                                if (isEditing)
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    onPressed: () {
                                      record.tasks.remove(task);
                                      if (record.tasks.isEmpty) {
                                        WeeklyRecordBox.box.deleteAt(index);
                                      } else {
                                        WeeklyRecordBox.box.putAt(index, record);
                                      }
                                      setState(() {});
                                    },
                                  ),
                              ],
                            ),
                          ),
                        )).toList(),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
