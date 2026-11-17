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

  const SensitiveImageCard({
    super.key,
    required this.imageUrl,
    this.caption = '',
    this.category = 'Forensic Evidence',
    this.initialBlur = true,
    this.height = 180,
    this.width,
    this.fit = BoxFit.cover,
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          // Background Image
          Image.network(
            widget.imageUrl,
            height: widget.height,
            width: widget.width,
            fit: widget.fit,
            errorBuilder: (_, _, _) => Container(
              height: widget.height,
              width: widget.width,
              color: const Color(0xFFF1F5F9),
              child: const Center(
                child: Icon(Icons.broken_image_outlined, color: AppColors.slate400, size: 36),
              ),
            ),
          ),

          // Blur filter when active
          if (_isBlurred)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.55),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.visibility_off_outlined,
                              color: AppColors.goldBright,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Sensitive Forensic Photo',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Click reveal to view for identification',
                            style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => setState(() => _isBlurred = false),
                            icon: const Icon(Icons.remove_red_eye_outlined, size: 13),
                            label: const Text('Reveal Image', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.slate900,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Top Badge (Category)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Text(
                widget.category.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // If unblurred, small button to re-blur
          if (!_isBlurred)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filled(
                onPressed: () => setState(() => _isBlurred = true),
                icon: const Icon(Icons.visibility_off_outlined, size: 15),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.65),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(6),
                ),
                tooltip: 'Re-blur image',
              ),
            ),

          // Caption Bar at bottom
          if (widget.caption.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  widget.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
