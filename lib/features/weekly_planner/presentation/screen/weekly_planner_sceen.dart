// weekly_planner_screen.dart
import 'package:flutter/material.dart';
import 'package:abeul_planner/core/widgets/custom_app_bar.dart';
import 'package:abeul_planner/core/text_styles.dart';
import 'package:abeul_planner/core/color.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/features/weekly_planner/data/model/weekly_task_model.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/provider/weekly_task_provider.dart';
import 'package:abeul_planner/features/weekly_planner/presentation/widget/weekly_tab_content.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 주간 플래너 메인 화면
/// - 요일별 탭(TabBar) 구성
/// - FloatingActionButton을 통해 할 일 추가
/// - 편집 버튼을 통해 테마 수정 가능
class WeeklyPlannerScreen extends ConsumerStatefulWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  ConsumerState<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends ConsumerState<WeeklyPlannerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final List<String> days = ['월', '화', '수', '목', '금', '토', '일'];
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: days.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 할 일 추가 다이얼로그 표시
  void _showAddTaskDialog(BuildContext context) {
    String selectedDay = days.first;
    final TextEditingController _contentController = TextEditingController();
    String priority = '보통';
    final List<String> _priorityKeys = ['낮음', '보통', '중요'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('플래너 추가', style: AppTextStyles.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedDay,
              items: days
                  .map((day) => DropdownMenuItem(
                        value: day,
                        child: Text(day, style: AppTextStyles.body),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) selectedDay = value;
              },
              decoration: const InputDecoration(labelText: '요일 선택'),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: '할 일 내용'),
            ),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String>(
              value: priority,
              items: _priorityKeys
                  .map((level) => DropdownMenuItem(
                        value: level,
                        child: Text(level, style: AppTextStyles.body),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) priority = value;
              },
              decoration: const InputDecoration(labelText: '중요도'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('취소', style: AppTextStyles.body.copyWith(color: AppColors.subText)),
          ),
          ElevatedButton(
            onPressed: () {
              final content = _contentController.text.trim();
              if (content.isEmpty) return;
              ref.read(weeklyTaskProvider.notifier).addTask(
                selectedDay,
                WeeklyTask(content: content, priority: priority),
              );
              Navigator.of(context).pop();
              setState(() {
                _tabController.index = days.indexOf(selectedDay);
              });
            },
            child: Text('추가', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: days.length,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight + 48.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomAppBar(
                title: '',
                isTransparent: true,
                actions: [
                  TextButton(
                    onPressed: () => setState(() => _isEditing = !_isEditing),
                    child: Text(
                      _isEditing ? '완료' : '편집',
                      style: AppTextStyles.body.copyWith(color: AppColors.text),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(width: 3.h, color: AppColors.highlight),
                      insets: EdgeInsets.symmetric(horizontal: 8.w), // ✅ 탭 내부만 색칠되도록 조정
                    ),
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: AppColors.text,
                    unselectedLabelColor: AppColors.subText,
                    labelStyle: AppTextStyles.body,
                    tabs: List.generate(days.length, (index) {
                      return Container(
                        alignment: Alignment.center,
                        child: Text(days[index]),
                      );
                    }),
                    dividerColor: AppColors.primary,
                    indicatorPadding: EdgeInsets.zero,
                    padding: EdgeInsets.zero,
                    labelPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddTaskDialog(context),
          backgroundColor: AppColors.accent,
          child: const Icon(Icons.add),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
              border: Border.all(color: AppColors.primary),
            ),
            child: TabBarView(
              controller: _tabController,
              children: days.map((day) {
                return WeeklyTabContent(day: day, isEditing: _isEditing);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}