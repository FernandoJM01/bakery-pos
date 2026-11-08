import 'dart:io';
import 'dart:typed_data';

Future<String> saveFile(String name, Uint8List bytes, String mimeType) async {
  final file = File('${Directory.systemTemp.path}/$name');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}
