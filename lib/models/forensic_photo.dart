class ForensicPhoto {
  final String id;
  final String category; // 'face', 'full_body', 'scars', 'tattoos', 'dental', 'clothing', 'belongings'
  final String caption;
  final String previewUrl;
  final String? thumbUrl;
  final String? archiveUrl;
  final bool isSensitive;
  final bool isPrimary;
  final String? savingsPercentage;

  const ForensicPhoto({
    required this.id,
    required this.category,
    required this.caption,
    required this.previewUrl,
    this.thumbUrl,
    this.archiveUrl,
    this.isSensitive = true,
    this.isPrimary = false,
    this.savingsPercentage,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'caption': caption,
        'preview_url': previewUrl,
        'thumb_url': thumbUrl,
        'archive_url': archiveUrl,
        'is_sensitive': isSensitive,
        'is_primary': isPrimary,
        'savings_percentage': savingsPercentage,
      };

  factory ForensicPhoto.fromJson(Map<String, dynamic> json) => ForensicPhoto(
        id: json['id'] ?? '',
        category: json['category'] ?? 'general',
        caption: json['caption'] ?? '',
        previewUrl: json['preview_url'] ?? '',
        thumbUrl: json['thumb_url'],
        archiveUrl: json['archive_url'],
        isSensitive: json['is_sensitive'] ?? true,
        isPrimary: json['is_primary'] ?? false,
        savingsPercentage: json['savings_percentage'],
      );
}

