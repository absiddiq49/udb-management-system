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
    final isCompact = widget.height < 90 || (widget.width != null && widget.width! < 90);

    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height,
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.network(
              widget.imageUrl,
              fit: widget.fit,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFFF1F5F9),
                child: Center(
                  child: isCompact
                      ? const Icon(Icons.broken_image_outlined, color: AppColors.slate400, size: 20)
                      : const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.broken_image_outlined, color: AppColors.slate400, size: 28),
                            SizedBox(height: 4),
                            Text(
                              'Media Unavailable',
                              style: TextStyle(color: AppColors.slate500, fontSize: 10.5, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            // Forensic Blur Filter
            if (_isBlurred)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 4 : 14,
                      vertical: isCompact ? 4 : 10,
                    ),
                    child: Center(
                      child: isCompact
                          ? InkWell(
                              onTap: () => setState(() => _isBlurred = false),
                              child: const Icon(
                                Icons.visibility_off_rounded,
                                color: AppColors.goldBright,
                                size: 18,
                              ),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withValues(alpha: 0.25),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 1),
                                  ),
                                  child: const Icon(
                                    Icons.visibility_off_rounded,
                                    color: AppColors.goldBright,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  'Sensitive Forensic Media',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    letterSpacing: -0.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Protected by Sensitivity Policy',
                                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () => setState(() => _isBlurred = false),
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.remove_red_eye_rounded, size: 12, color: AppColors.slate900),
                                        SizedBox(width: 4),
                                        Text(
                                          'Reveal Image',
                                          style: TextStyle(
                                            color: AppColors.slate900,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
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

            // Category Badge & Re-blur Button
            if (!_isBlurred && !isCompact)
              Positioned(
                top: 8,
                right: 8,
                child: InkWell(
                  onTap: () => setState(() => _isBlurred = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility_off, color: Colors.white, size: 11),
                        SizedBox(width: 3),
                        Text('Blur', style: TextStyle(color: Colors.white, fontSize: 9.5)),
                      ],
                    ),
                  ),
                ),
              ),

            if (widget.caption.isNotEmpty && !isCompact)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: Colors.black54,
                  child: Text(
                    widget.caption,
                    style: const TextStyle(color: Colors.white, fontSize: 9.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
