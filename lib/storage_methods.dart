import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageMethods {
  Future<String> getUploadedImage(Uint8List file) async {
    final String bucketName = 'products'; // Ensure this is correct
    final String fileName = 'product${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      final response = await Supabase.instance.client.storage.from(bucketName).uploadBinary(
        fileName,
        file,
      );

      // Check if the upload was successful
      if (response.isEmpty) {
        print("Upload failed: Empty response");
        return 'null';
      }

      // Get public URL
      final String publicUrl = Supabase.instance.client.storage.from(bucketName).getPublicUrl(fileName);
      print("Uploaded Image URL: $publicUrl");

      return publicUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return 'null';
    }
  }
}
