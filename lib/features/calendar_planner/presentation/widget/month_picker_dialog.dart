// features/calendar_planner/presentation/widget/month_picker_dialog.dart
import 'package:flutter/material.dart';

Future<DateTime?> showMonthYearPickerDialog(BuildContext context, DateTime initialDate) async {
  int selectedYear = initialDate.year;
  int selectedMonth = initialDate.month;

  return showDialog<DateTime>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('연도와 월 선택'),
        content: SizedBox(
          height: 100,
          child: Row(
            children: [
              Expanded(
                child: DropdownButton<int>(
                  value: selectedYear,
                  isExpanded: true,
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
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButton<int>(
                  value: selectedMonth,
                  isExpanded: true,
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, DateTime(selectedYear, selectedMonth));
            },
            child: const Text('확인'),
          ),
        ],
      );
    },
  );
}