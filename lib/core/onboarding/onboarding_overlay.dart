// core/onboarding/onboarding_overlay.dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:abeul_planner/core/styles/color.dart';
import 'package:abeul_planner/core/styles/text_styles.dart';

class OnboardingOverlay extends StatefulWidget {
  final List<OnboardingStep> steps;
  final int currentStep;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onSkip;
  final VoidCallback onComplete;
  final ScrollController? scrollController;

  const OnboardingOverlay({
    super.key,
    required this.steps,
    required this.currentStep,
    required this.onNext,
    required this.onPrevious,
    required this.onSkip,
    required this.onComplete,
    this.scrollController,
  });

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay> {
  Rect? _targetRect;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _updateTargetRect();
    });
  }

  @override
  void didUpdateWidget(OnboardingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _updateTargetRect();
        _scrollToTarget();
      });
    }
  }

  void _updateTargetRect() {
    if (widget.currentStep >= widget.steps.length) return;
    
    final step = widget.steps[widget.currentStep];
    if (step.targetKey?.currentContext != null) {
      final RenderBox renderBox = step.targetKey!.currentContext!.findRenderObject() as RenderBox;
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      
      setState(() {
        _targetRect = Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
      });
    } else {
      setState(() {
        _targetRect = null;
      });
    }
  }

  void _scrollToTarget() {
    if (_targetRect == null || widget.scrollController == null || !widget.scrollController!.hasClients) return;
    
    final screenHeight = MediaQuery.of(context).size.height;
    final dialogHeight = 200.h;
    final targetCenter = _targetRect!.center.dy;
    final dialogPosition = screenHeight - dialogHeight - 100.h;
    
    if (targetCenter > dialogPosition - 100.h) {
      final scrollOffset = targetCenter - (dialogPosition - 150.h);
      widget.scrollController!.animateTo(
        widget.scrollController!.offset + scrollOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentStep >= widget.steps.length) return const SizedBox.shrink();

    final step = widget.steps[widget.currentStep];
    final isFirstStep = widget.currentStep == 0;
    final isLastStep = widget.currentStep == widget.steps.length - 1;

    return Stack(
      children: [
        // 반투명 배경과 하이라이트를 함께 처리
        Positioned.fill(
          child: CustomPaint(
            painter: OverlayPainter(
              targetRect: _targetRect,
              overlayColor: Colors.black.withAlpha((0.7 * 255).toInt()),
            ),
          ),
        ),
        
        // 하이라이트 테두리
        if (_targetRect != null) _buildHighlightBorder(),
        
        // 고정 위치 설명 박스 (별도의 Material로 감싸서 elevation 적용)
        _buildFixedDescriptionBox(step, isFirstStep, isLastStep),
      ],
    );
  }

  Widget _buildHighlightBorder() {
    if (_targetRect == null) return const SizedBox.shrink();
    
    return Positioned(
      left: _targetRect!.left - 4.w,
      top: _targetRect!.top - 4.h,
      child: Container(
        width: _targetRect!.width + 8.w,
        height: _targetRect!.height + 8.h,
        decoration: BoxDecoration(
          color: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildFixedDescriptionBox(OnboardingStep step, bool isFirstStep, bool isLastStep) {
    // 종합 플래너 // 일상 플래너 단계일 때만 다이얼로그를 위로 올리기
    final isDailyPlannerStep = step.title == '일상 플래너';
    // 일상 플래너 // 일정 추가하기 단계일 때도 다이얼로그를 위로 올리기
    final isAddTaskStep = step.title == '일정 추가하기';
    final bottomPosition = isDailyPlannerStep ? 350.h : isAddTaskStep ? 160.h : 100.h;
    
    return Positioned(
      left: 16.w,
      right: 16.w,
      bottom: bottomPosition,
      child: Material(
        elevation: 12, // 설명 박스만 elevation 적용
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                step.title,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                step.description,
                style: AppTextStyles.body,
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 진행 상황 표시
                  Row(
                    children: List.generate(
                      widget.steps.length,
                      (index) => Container(
                        margin: EdgeInsets.only(right: 4.w),
                        width: 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index <= widget.currentStep
                              ? AppColors.primary
                              : AppColors.subText.withAlpha((0.3 * 255).toInt()),
                        ),
                      ),
                    ),
                  ),
                  
                  // 버튼들
                  Row(
                    children: [
                      // 이전 버튼
                      if (!isFirstStep)
                        ElevatedButton(
                          onPressed: widget.onPrevious,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.lightPrimary,
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                            child: Text(
                              '이전',
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      
                      if (!isFirstStep) SizedBox(width: 8.w),
                      
                      // 다음/완료 버튼
                      ElevatedButton(
                        onPressed: isLastStep ? widget.onComplete : widget.onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          child: Text(
                            isLastStep ? '완료' : '다음',
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OverlayPainter extends CustomPainter {
  final Rect? targetRect;
  final Color overlayColor;

  OverlayPainter({
    required this.targetRect,
    required this.overlayColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 전체 화면에 어두운 오버레이 그리기
    final overlayPaint = Paint()..color = overlayColor;
    final fullScreenRect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    if (targetRect != null) {
      // Path를 사용하여 하이라이트 영역을 제외한 부분만 어둡게 처리
      final path = Path()
        ..addRect(fullScreenRect)
        ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(
            targetRect!.left - 8,
            targetRect!.top - 8,
            targetRect!.width + 16,
            targetRect!.height + 16,
          ),
          Radius.circular(12.r),
        ));
      
      // Path fill type을 evenOdd로 설정하여 겹치는 부분은 투명하게 만들기
      path.fillType = PathFillType.evenOdd;
      canvas.drawPath(path, overlayPaint);
    } else {
      // 타겟이 없으면 전체 화면을 어둡게
      canvas.drawRect(fullScreenRect, overlayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant OverlayPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
           oldDelegate.overlayColor != overlayColor;
  }
}

class OnboardingStep {
  final String title;
  final String description;
  final GlobalKey? targetKey;

  const OnboardingStep({
    required this.title,
    required this.description,
    this.targetKey,
  });
}