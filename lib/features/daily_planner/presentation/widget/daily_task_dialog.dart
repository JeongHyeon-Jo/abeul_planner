// daily_task_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';
import 'package:abeul_planner/core/utils/priority_icon.dart';
import 'package:abeul_planner/features/daily_planner/data/model/daily_task_model.dart';
import 'package:abeul_planner/features/daily_planner/presentation/provider/daily_task_provider.dart';
import 'package:abeul_planner/features/daily_planner/presentation/widget/daily_delete_dialog.dart';

class DailyTaskDialog extends ConsumerStatefulWidget {
  final DailyTaskModel? task;
  final int? index;
  final TextEditingController situationController;
  final TextEditingController actionController;
  final String selectedPriority;
  final ValueChanged<int> onDelete;

  const DailyTaskDialog({
    super.key,
    required this.task,
    required this.index,
    required this.situationController,
    required this.actionController,
    required this.selectedPriority,
    required this.onDelete,
  });

  @override
  ConsumerState<DailyTaskDialog> createState() => _DailyTaskDialogState();
}

class _DailyTaskDialogState extends ConsumerState<DailyTaskDialog> {
  late TextEditingController _goalController;
  bool _isAlways = false;
  bool _isImportant = false;

  @override
  void initState() {
    super.initState();
    _goalController = TextEditingController();

    final goal = widget.task?.goalCount;
    if (widget.task != null) {
      _isAlways = goal == null;
      _goalController.text = goal?.toString() ?? '';
    } else {
      _isAlways = false;
      _goalController.text = '';
    }

    _isImportant = widget.selectedPriority == '중요';
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  void _showRepeatInfo() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 아이콘과 제목
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColors.lightPrimary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    '반복 설정 안내',
                    style: AppTextStyles.title.copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              
              // 설명 내용
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.primary,
                    width: 1.w,
                  ),
                ),
                child: Text(
                  '반복할 횟수를 정할 수 있습니다.\n횟수를 입력하지 않으면\n일정을 제거하기 전까지 항상 반복됩니다.',
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14.sp,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 24.h),
              
              // 확인 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    '확인',
                    style: AppTextStyles.button.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.task != null;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    isEditMode ? '일정 수정' : '새 일정 추가',
                    style: AppTextStyles.title,
                  ),
                ),
                SizedBox(height: 24.h),
      
                TextField(
                  controller: widget.situationController,
                  decoration: InputDecoration(
                    labelText: '언제',
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.highlight, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
      
                TextField(
                  controller: widget.actionController,
                  decoration: InputDecoration(
                    labelText: '일정 내용',
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.highlight, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
      
                // 중요도
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isImportant = !_isImportant;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      border: Border.all(
                        color: _isImportant ? AppColors.highlight : AppColors.primary,
                        width: 2.w,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        getPriorityIcon('중요') ?? const SizedBox(),
                        SizedBox(width: 6.w),
                        Text('중요 일정', style: AppTextStyles.body),
                        Spacer(),
                        if (_isImportant)
                          Icon(Icons.check, color: AppColors.success)
                        else
                          Icon(Icons.check, color: AppColors.subText),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                // 반복
                if (!isEditMode) ...[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isAlways = !_isAlways;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2.w,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Text('반복', style: AppTextStyles.body),
                          Spacer(),
                          GestureDetector(
                            onTap: _showRepeatInfo,
                            child: Container(
                              padding: EdgeInsets.all(2.w),
                              child: Icon(
                                Icons.info_outline,
                                size: 24.sp,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: _goalController.text.trim().isEmpty
                                      ? AppColors.divider
                                      : AppColors.primary,
                                ),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: TextField(
                                controller: _goalController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                enabled: true,
                                style: AppTextStyles.body,
                                textAlign: TextAlign.center,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  hintText: '숫자 입력',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                // 일정 제거 버튼
                if (isEditMode) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder: (_) => DailyDeleteDialog(index: widget.index!),
                        );
                        if (shouldDelete == true && context.mounted) {
                          Navigator.of(context).pop();
                          widget.onDelete(widget.index!);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text('일정 제거',
                          style: AppTextStyles.body.copyWith(color: Colors.white)),
                    ),
                  ),
                ],
      
                SizedBox(height: 16.h),
      
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        widget.situationController.clear();
                        widget.actionController.clear();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightPrimary,
                        foregroundColor: AppColors.text,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        child: Text('취소', style: AppTextStyles.body),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final situation = widget.situationController.text.trim();
                        final action = widget.actionController.text.trim();
                        if (situation.isEmpty || action.isEmpty) return;
      
                        final goal = _isAlways
                            ? null
                            : int.tryParse(_goalController.text.trim());
      
                        final newTask = DailyTaskModel(
                          situation: situation,
                          action: action,
                          isCompleted: widget.task?.isCompleted ?? false,
                          priority: _isImportant ? '중요' : '보통',
                          goalCount: goal,
                          completedCount: widget.task?.completedCount ?? 0,
                        );
      
                        if (widget.task == null) {
                          ref.read(dailyTaskProvider.notifier).addTask(newTask);
                        } else {
                          ref.read(dailyTaskProvider.notifier).editTask(widget.index!, newTask);
                        }
      
                        widget.situationController.clear();
                        widget.actionController.clear();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        child: Text('저장', style: AppTextStyles.button),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}