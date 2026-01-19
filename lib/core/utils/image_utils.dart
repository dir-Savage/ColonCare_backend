import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageUtils {
  static Future<Uint8List> compressImage(File imageFile, {int maxWidth = 800, int quality = 85}) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) throw Exception('Invalid image file');

    // Resize if needed
    final resized = img.copyResize(image, width: maxWidth);

    // Encode with compression
    final compressedBytes = img.encodeJpg(resized, quality: quality);
    return compressedBytes;
  }
}