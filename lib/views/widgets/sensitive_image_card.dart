import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SensitiveImageCard extends StatefulWidget {
  final String imageUrl;
  final String caption;
  final String category;
  final bool initialBlur;
  final double height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const SensitiveImageCard({
    super.key,
    required this.imageUrl,
    this.caption = '',
    this.category = 'Forensic Evidence',
    this.initialBlur = true,
    this.height = 160,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  State<SensitiveImageCard> createState() => _SensitiveImageCardState();
}

class _SensitiveImageCardState extends State<SensitiveImageCard> {
  late bool _isBlurred;

  @override
  void initState() {
    super.initState();
    _isBlurred = widget.initialBlur;
  }

  @override
  void didUpdateWidget(SensitiveImageCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialBlur != widget.initialBlur) {
      _isBlurred = widget.initialBlur;
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(12);

    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height,
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image (Stretches across 100% width and height)
            Image.network(
              widget.imageUrl,
              fit: widget.fit,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFFF1F5F9),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.broken_image_outlined, color: AppColors.slate400, size: 30),
                      SizedBox(height: 4),
                      Text(
                        'Media Preview Unavailable',
                        style: TextStyle(color: AppColors.slate500, fontSize: 10.5, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Sleek High-Grade Forensic Blur Filter
            if (_isBlurred)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.65),
                          Colors.black.withValues(alpha: 0.85),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.25),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 1),
                            ),
                            child: const Icon(
                              Icons.visibility_off_rounded,
                              color: AppColors.goldBright,
                              size: 18,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Sensitive Forensic Crime Scene Media',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.5,
                              letterSpacing: -0.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Protected by Police Regulations & Family Sensitivity Policy',
                            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9.5),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => setState(() => _isBlurred = false),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5.5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.remove_red_eye_rounded, size: 13, color: AppColors.slate900),
                                  SizedBox(width: 5),
                                  Text(
                                    'Reveal Forensic Image',
                                    style: TextStyle(
                                      color: AppColors.slate900,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Top Badge (Category tag e.g. [FACE], [TATTOO])
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppColors.goldBright,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // If unblurred, sleek button on top right to re-blur
            if (!_isBlurred)
              Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                  onTap: () => setState(() => _isBlurred = true),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility_off_rounded, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Hide',
                          style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Caption Bar at bottom
            if (widget.caption.isNotEmpty)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.85),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    widget.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
