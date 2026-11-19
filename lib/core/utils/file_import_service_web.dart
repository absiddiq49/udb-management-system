import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
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
  final completer = Completer<PickedImageFile?>();
  final input = html.FileUploadInputElement()..accept = 'image/*';
  if (useCamera) {
    input.setAttribute('capture', 'environment');
  }
  input.click();

  input.onChange.listen((event) {
    final files = input.files;
    if (files != null && files.isNotEmpty) {
      final file = files.first;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoadEnd.listen((event) {
        final result = reader.result;
        Uint8List? bytes;
        if (result is Uint8List) {
          bytes = result;
        } else if (result is ByteBuffer) {
          bytes = result.asUint8List();
        } else if (result is List<int>) {
          bytes = Uint8List.fromList(result);
        }

        final base64Str = bytes != null ? base64Encode(bytes) : '';
        final mimeType = file.type.isNotEmpty ? file.type : 'image/jpeg';
        final dataUrl = 'data:$mimeType;base64,$base64Str';

        completer.complete(PickedImageFile(
          name: file.name.isNotEmpty ? file.name : (useCamera ? 'camera_capture.jpg' : 'image.jpg'),
          dataUrl: dataUrl,
          bytes: bytes,
          sizeInBytes: file.size,
        ));
      });
      reader.onError.listen((error) {
        completer.complete(null);
      });
    } else {
      completer.complete(null);
    }
  });

  return completer.future;
}

Future<PickedImageFile?> pickImageFromCamera() async {
  return pickImageFromDevice(useCamera: true);
}
