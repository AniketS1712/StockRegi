import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A custom inventory-themed loading indicator featuring animated bouncing packages.
class AppLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;

  const AppLoadingIndicator({super.key, this.size = 40, this.color});

  @override
  State<AppLoadingIndicator> createState() => _AppLoadingIndicatorState();
}

class _AppLoadingIndicatorState extends State<AppLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.color ?? AppColors.primary;
    final boxSize = widget.size * 0.5;
    final maxJump = widget.size * 0.3;
    final spacing = widget.size * 0.1;
    const packageCount = 5;

    final indicatorWidth = packageCount * (boxSize + spacing);

    return SizedBox(
      width: indicatorWidth,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(packageCount, (index) {
              final phaseOffset = index * 0.3;
              final t = (_controller.value + phaseOffset) % 1.0;
              final jumpFraction = math.sin(t * math.pi).clamp(0.0, 1.0);

              final elevation = jumpFraction * maxJump;
              final scaleY =
                  1.0 - (1.0 - jumpFraction) * 0.12 + (jumpFraction * 0.06);
              final scaleX =
                  1.0 + (1.0 - jumpFraction) * 0.08 - (jumpFraction * 0.04);
              final shadowOpacity = (0.28 - jumpFraction * 0.20).clamp(
                0.05,
                0.3,
              );
              final shadowWidth = (boxSize * 0.9) * (1.0 - jumpFraction * 0.35);

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Bouncing Package Box
                    Transform.translate(
                      offset: Offset(0, -elevation),
                      child: Transform.scale(
                        scaleX: scaleX,
                        scaleY: scaleY,
                        alignment: Alignment.bottomCenter,
                        child: _InventoryPackageBox(
                          size: boxSize,
                          color: baseColor,
                          index: index,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Dynamic Ground Shadow
                    Container(
                      width: shadowWidth,
                      height: boxSize * 0.16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.elliptical(shadowWidth, boxSize * 0.16),
                        ),
                        color: Colors.black.withValues(alpha: shadowOpacity),
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _InventoryPackageBox extends StatelessWidget {
  final double size;
  final Color color;
  final int index;

  const _InventoryPackageBox({
    required this.size,
    required this.color,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final boxColor = index == 1
        ? Color.lerp(color, AppColors.primaryContainer, 0.45)!
        : color;

    final borderRadius = BorderRadius.circular(size * 0.18);
    final tapeWidth = size * 0.26;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: borderRadius,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: boxColor.withValues(alpha: 0.35),
            blurRadius: 3,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vertical packing tape band
          Container(
            width: tapeWidth,
            height: size,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          // Horizontal packaging strap line
          Container(
            width: size,
            height: size * 0.12,
            color: Colors.black.withValues(alpha: 0.08),
          ),
          // Top highlight bevel for 3D parcel feel
          Positioned(
            top: 1,
            left: 2,
            right: 2,
            child: Container(
              height: size * 0.18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(size * 0.14),
                ),
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
