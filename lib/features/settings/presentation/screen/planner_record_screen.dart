// planner_record_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/features/daily_planner/presentation/provider/daily_task_provider.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/provider/weekly_task_provider.dart';
import 'package:abeul_planner/features/calendar_planner/presentation/provider/calendar_task_provider.dart';
import 'package:abeul_planner/features/daily_planner/data/model/daily_task_model.dart';
import 'package:abeul_planner/features/weekly_planner/data/model/weekly_task_model.dart';
import 'package:abeul_planner/features/calendar_planner/data/model/calendar_task_model.dart';

enum PlannerType { daily, weekly, calendar }

class PlannerRecordScreen extends ConsumerStatefulWidget {
  final PlannerType type;
  const PlannerRecordScreen({super.key, required this.type});

  @override
  ConsumerState<PlannerRecordScreen> createState() => _PlannerRecordScreenState();
}

class _PlannerRecordScreenState extends ConsumerState<PlannerRecordScreen> {
  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    final title = _getTitle();

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: AppTextStyles.title.copyWith(color: AppColors.text)),
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
            onPressed: _deleteAll,
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: _buildRecordList(),
      ),
    );
  }

  String _getTitle() {
    switch (widget.type) {
      case PlannerType.daily:
        return '일상 플래너 기록';
      case PlannerType.weekly:
        return '주간 플래너 기록';
      case PlannerType.calendar:
        return '달력 플래너 기록';
    }
  }

  void _deleteAll() {
    switch (widget.type) {
      case PlannerType.daily:
        ref.read(dailyTaskProvider.notifier).clear();
        break;
      case PlannerType.weekly:
        ref.read(weeklyTaskProvider.notifier).clear();
        break;
      case PlannerType.calendar:
        ref.read(calendarTaskProvider.notifier).clear();
        break;
    }
  }

  Widget _buildRecordList() {
    switch (widget.type) {
      case PlannerType.daily:
        final dailyList = ref.watch(dailyTaskProvider);
        return _buildSection(dailyList, (task, i) => '${task.situation} → ${task.action}', task => task.isCompleted);

      case PlannerType.weekly:
        final weeklyList = ref.watch(weeklyTaskProvider);
        final allTasks = weeklyList.entries.expand((e) => e.value.map((t) => (e.key, t))).toList();
        return _buildSection(allTasks, (entry, i) => '${entry.}요일: ${entry..content}', t => t.priority == '중요');

      case PlannerType.calendar:
        final calendarList = ref.watch(calendarTaskProvider);
        return _buildSection(calendarList, (task, i) => '${DateFormat('MM/dd').format(task.date)}: ${task.memo}', t => t.priority == '중요');
    }
  }

  Widget _buildSection<T>(List<T> data, String Function(T, int) textBuilder, bool Function(T) isChecked) {
    if (data.isEmpty) return const Center(child: Text('기록이 없습니다'));

    return ListView.separated(
      itemCount: data.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final item = data[index];
        return ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r), side: BorderSide(color: AppColors.border)),
          leading: Icon(isChecked(item) ? Icons.check_circle : Icons.radio_button_unchecked, color: AppColors.primary),
          title: Text(textBuilder(item, index), style: AppTextStyles.body),
          trailing: isEditing
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _deleteItem(item),
                )
              : null,
        );
      },
    );
  }

  void _deleteItem(dynamic item) {
    switch (widget.type) {
      case PlannerType.daily:
        final index = ref.read(dailyTaskProvider).indexOf(item);
        if (index != -1) ref.read(dailyTaskProvider.notifier).deleteAt(index);
        break;
      case PlannerType.weekly:
        final map = ref.read(weeklyTaskProvider);
        for (final entry in map.entries) {
          final idx = entry.value.indexOf(item);
          if (idx != -1) {
            ref.read(weeklyTaskProvider.notifier).deleteTask(entry.key, idx);
            break;
          }
        }
        break;
      case PlannerType.calendar:
        ref.read(calendarTaskProvider.notifier).deleteSpecificTask(item);
        break;
    }
  }
}
