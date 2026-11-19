import 'dart:typed_data';

class PickedImageFile {
  final String name;
  final String dataUrl;
  final Uint8List? bytes;
  final int sizeInBytes;

  const PickedImageFile({
    required this.name,
    required this.dataUrl,
    this.bytes,
    required this.sizeInBytes,
  });

  String get humanSize {
    if (sizeInBytes < 1024) return '$sizeInBytes B';
    if (sizeInBytes < 1024 * 1024) return '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

Future<PickedImageFile?> pickImageFromDevice({bool useCamera = false}) async {
  // Stub for tests / VM
  return PickedImageFile(
    name: useCamera ? 'camera_snapshot.jpg' : 'forensic_evidence_sample.jpg',
    dataUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=600&q=80',
    bytes: Uint8List(0),
    sizeInBytes: 1024 * 350,
  );
}

Future<PickedImageFile?> pickImageFromCamera() async {
  return pickImageFromDevice(useCamera: true);
}
