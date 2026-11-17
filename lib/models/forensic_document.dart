class ForensicDocument {
  final String id;
  final String type; // 'inquest_report', 'postmortem_report', 'dna_report', 'toxicology'
  final String title;
  final String referenceNumber;
  final String originalName;
  final String sizeHuman;
  final String fileUrl;
  final String sha256Hash;
  final String uploadedAt;

  const ForensicDocument({
    required this.id,
    required this.type,
    required this.title,
    required this.referenceNumber,
    required this.originalName,
    required this.sizeHuman,
    required this.fileUrl,
    required this.sha256Hash,
    required this.uploadedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'reference_number': referenceNumber,
        'original_name': originalName,
        'size_human': sizeHuman,
        'file_url': fileUrl,
        'sha256_hash': sha256Hash,
        'uploaded_at': uploadedAt,
      };

  factory ForensicDocument.fromJson(Map<String, dynamic> json) =>
      ForensicDocument(
        id: json['id'] ?? '',
        type: json['type'] ?? 'document',
        title: json['title'] ?? '',
        referenceNumber: json['reference_number'] ?? '',
        originalName: json['original_name'] ?? 'document.pdf',
        sizeHuman: json['size_human'] ?? '1.2 MB',
        fileUrl: json['file_url'] ?? '',
        sha256Hash: json['sha256_hash'] ?? '',
        uploadedAt: json['uploaded_at'] ?? 'Verified',
      );
}

