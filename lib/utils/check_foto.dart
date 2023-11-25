import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:stunt_application/models/user.dart';

class Foto {
  Future<File> check(User user) async {
    File imageFile = File('');
    String dir = (await getApplicationDocumentsDirectory()).path;
    bool checkFoto = await File('$dir/${user.userID}.jpg').exists();
    String path = '$dir/${user.userID}.jpg';
    if (checkFoto) {
      imageFile = File(path);
    } else {
      if (user.foto != null && user.foto!.isNotEmpty) {
        Uint8List bytes = base64.decode(user.foto.toString());
        File file = File(path);
        await file.writeAsBytes(bytes);
        imageFile = File(path);
      }
    }
    return imageFile;
  }
}
