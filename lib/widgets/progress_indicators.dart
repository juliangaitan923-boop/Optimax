import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/constants.dart';

class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              colors: [
                AppColors.surfaceCard.withOpacity(0.3),
                AppColors.surfaceCardLight.withOpacity(0.5),
                AppColors.surfaceCard.withOpacity(0.3),
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment(-1.0 + _controller.value * 2, 0),
              end: Alignment(1.0 + _controller.value * 2, 0),
            ),
          ),
        );
      },
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final int lineCount;

  const SkeletonCard({super.key, this.lineCount = 3});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: AppColors.surfaceCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLoading(width: 120, height: 18, borderRadius: 4),
          const SizedBox(height: 16),
          ...List.generate(
            lineCount,
            (i) => Padding(
              padding: EdgeInsets.only(bottom: i < lineCount - 1 ? 10 : 0),
              child: ShimmerLoading(
                width: 120 + math.Random().nextInt(180).toDouble(),
                height: 14,
                borderRadius: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedCircularScore extends StatefulWidget {
  final int score;
  final double size;

  const AnimatedCircularScore({
    super.key,
    required this.score,
    this.size = 160,
  });

  @override
  State<AnimatedCircularScore> createState() => _AnimatedCircularScoreState();
}

class _AnimatedCircularScoreState extends State<AnimatedCircularScore>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCircularScore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _scoreColor {
    if (widget.score >= 80) return AppColors.success;
    if (widget.score >= 50) return AppColors.warning;
    return const Color(0xFFFF6B6B);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final displayScore = (widget.score * _animation.value).toInt();
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  value: widget.score / 100.0 * _animation.value,
                  strokeWidth: 10,
                  backgroundColor: Colors.white.withOpacity(0.04),
                  valueColor: AlwaysStoppedAnimation<Color>(_scoreColor.withOpacity(0.8)),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Container(
                width: widget.size * 0.7,
                height: widget.size * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      _scoreColor.withOpacity(0.08),
                      _scoreColor.withOpacity(0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$displayScore',
                      style: TextStyle(
                        fontSize: widget.size * 0.28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                    Text(
                      '/ 100',
                      style: TextStyle(
                        fontSize: widget.size * 0.09,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ResourceBar extends StatelessWidget {
  final String label;
  final int percent;
  final String value;
  final IconData icon;
  final Color? color;

  const ResourceBar({
    super.key,
    required this.label,
    required this.percent,
    required this.value,
    required this.icon,
    this.color,
  });

  Color get _barColor {
    if (color != null) return color!;
    if (percent >= 80) return const Color(0xFFFF6B6B);
    if (percent >= 50) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _barColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: _barColor),
            ),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: percent / 100.0,
            backgroundColor: Colors.white.withOpacity(0.04),
            valueColor: AlwaysStoppedAnimation<Color>(_barColor),
            minHeight: 7,
          ),
        ),
      ],
    );
  }
}
