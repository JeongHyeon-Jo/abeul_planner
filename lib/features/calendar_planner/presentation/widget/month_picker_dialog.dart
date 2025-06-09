// features/calendar_planner/presentation/widget/month_picker_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';

Future<DateTime?> showMonthYearPickerDialog(BuildContext context, DateTime initialDate) async {
  int selectedYear = initialDate.year;
  int selectedMonth = initialDate.month;

  return showDialog<DateTime>(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('연도와 월 선택', style: AppTextStyles.title),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary, width: 2.w),
                        borderRadius: BorderRadius.circular(12.r),
                        color: AppColors.cardBackground,
                      ),
                      child: DropdownButton<int>(
                        value: selectedYear,
                        isExpanded: true,
                        underline: SizedBox(),
                        items: List.generate(30, (i) {
                          final year = DateTime.now().year - 15 + i;
                          return DropdownMenuItem(value: year, child: Text('$year년'));
                        }),
                        onChanged: (value) {
                          if (value != null) {
                            selectedYear = value;
                            (context as Element).markNeedsBuild();
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary, width: 2.w),
                        borderRadius: BorderRadius.circular(12.r),
                        color: AppColors.cardBackground,
                      ),
                      child: DropdownButton<int>(
                        value: selectedMonth,
                        isExpanded: true,
                        underline: SizedBox(),
                        items: List.generate(12, (i) {
                          return DropdownMenuItem(value: i + 1, child: Text('${i + 1}월'));
                        }),
                        onChanged: (value) {
                          if (value != null) {
                            selectedMonth = value;
                            (context as Element).markNeedsBuild();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
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
                      Navigator.pop(context, DateTime(selectedYear, selectedMonth));
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
                      child: Text('확인', style: AppTextStyles.button),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
