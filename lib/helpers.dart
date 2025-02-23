import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

Future<Uint8List> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    final finalBytes = await File(pickedFile!.path).readAsBytes();
    return finalBytes;
  }