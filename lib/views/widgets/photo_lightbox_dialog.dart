import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/forensic_photo.dart';

class PhotoLightboxDialog extends StatefulWidget {
  final List<ForensicPhoto> photos;
  final int initialIndex;
  final bool initialBlur;

  const PhotoLightboxDialog({
    super.key,
    required this.photos,
    this.initialIndex = 0,
    this.initialBlur = false,
  });

  @override
  State<PhotoLightboxDialog> createState() => _PhotoLightboxDialogState();
}

class _PhotoLightboxDialogState extends State<PhotoLightboxDialog> {
  late int _currentIndex;
  late bool _isBlurred;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(
      0,
      widget.photos.isNotEmpty ? widget.photos.length - 1 : 0,
    );
    _isBlurred = widget.initialBlur;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (widget.photos.isEmpty) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('No photos catalogued for this case.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      );
    }

    final currentPhoto = widget.photos[_currentIndex];

    return Dialog(
      backgroundColor: isDark ? AppColors.darkCardBg : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960, maxHeight: 820),
        child: Column(
          children: [
            // Top Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.slate50,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.primaryBorder),
                    ),
                    child: Text(
                      currentPhoto.category.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Forensic Photo Inspection (${_currentIndex + 1} of ${widget.photos.length})',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.slate900,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Blur toggle button
                  OutlinedButton.icon(
                    onPressed: () => setState(() => _isBlurred = !_isBlurred),
                    icon: Icon(
                      _isBlurred
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 15,
                      color: _isBlurred ? AppColors.amber : AppColors.slate600,
                    ),
                    label: Text(
                      _isBlurred ? 'Sensitive Blur: ON' : 'Sensitive Blur: OFF',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _isBlurred
                            ? AppColors.amber
                            : AppColors.slate700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      side: BorderSide(
                        color: _isBlurred
                            ? AppColors.goldBorder
                            : AppColors.slate300,
                      ),
                      backgroundColor: _isBlurred
                          ? AppColors.goldLight
                          : Colors.transparent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDark ? AppColors.slate400 : AppColors.slate600,
                    ),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Close Lightbox',
                  ),
                ],
              ),
            ),

            // Main Image Viewer with navigation controls
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    color: Colors.black,
                    width: double.infinity,
                    height: double.infinity,
                    child: InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4.0,
                      child: Center(
                        child: Image.network(
                          currentPhoto.previewUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => Container(
                            color: Colors.black,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.broken_image_outlined,
                                  color: Colors.white54,
                                  size: 54,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Forensic media unavailable or network restricted',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Blur overlay if blurred
                  if (_isBlurred)
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.65),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.visibility_off_outlined,
                                  color: AppColors.goldBright,
                                  size: 48,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Sensitive Forensic Autopsy / Crime Scene Photo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Blurred for public respect and sensitivity.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      setState(() => _isBlurred = false),
                                  icon: const Icon(
                                    Icons.remove_red_eye_outlined,
                                    size: 16,
                                  ),
                                  label: const Text('Reveal Evidence Photo'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Left Navigation Arrow
                  if (widget.photos.length > 1 && _currentIndex > 0)
                    Positioned(
                      left: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        radius: 22,
                        child: IconButton(
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () => setState(() => _currentIndex--),
                          tooltip: 'Previous Photo',
                        ),
                      ),
                    ),

                  // Right Navigation Arrow
                  if (widget.photos.length > 1 &&
                      _currentIndex < widget.photos.length - 1)
                    Positioned(
                      right: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        radius: 22,
                        child: IconButton(
                          icon: const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () => setState(() => _currentIndex++),
                          tooltip: 'Next Photo',
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Bottom Caption & Thumbnail Strip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          currentPhoto.caption.isNotEmpty
                              ? currentPhoto.caption
                              : 'Forensic documentation capture',
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.slate800,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const Text(
                        'Pinch or scroll to zoom',
                        style: TextStyle(
                          color: AppColors.slate400,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  if (widget.photos.length > 1) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 52,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.photos.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          final p = widget.photos[idx];
                          final isSelected = idx == _currentIndex;
                          return InkWell(
                            onTap: () => setState(() => _currentIndex = idx),
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              width: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.slate300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.network(
                                p.previewUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    const Icon(Icons.image, size: 16),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
