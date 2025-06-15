// expandable_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';

// 제목 클릭 시 섹션을 확장/축소할 수 있는 공통 위젯
class ExpandableSection extends StatefulWidget {
  final String title;
  final String route;
  final Widget child;

  const ExpandableSection({
    super.key,
    required this.title,
    required this.route,
    required this.child,
  });

  @override
  State<ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<ExpandableSection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary, width: 1.2.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 타이틀 행
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Row(
                    children: [
                      Text(
                        widget.title,
                        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 20.sp,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: AppColors.subText,
                  onPressed: () => context.go(widget.route),
                ),
              ],
            ),
          ),
          if (_isExpanded) ... [
            const Divider(color: AppColors.primary, height: 0, thickness: 1),
            Padding(
              padding: EdgeInsets.all(16.0.w),
              child: widget.child,
            ),
          ],
        ],
      ),
    );
  }
}
