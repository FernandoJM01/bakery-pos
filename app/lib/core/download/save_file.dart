import 'dart:typed_data';

import 'save_file_io.dart'
    if (dart.library.js_interop) 'save_file_web.dart'
    as impl;

/// Hands [bytes] to the person as a file named [name]: a download in the
/// browser, a file in the temporary folder elsewhere. Returns where it went.
Future<String> saveFile(String name, Uint8List bytes, String mimeType) =>
    impl.saveFile(name, bytes, mimeType);
