import 'dart:convert';
import 'dart:io';

import 'package:bcore/bcore_platform_interface.dart';

String safeBase64Decode(String source) {
  final l = source.length % 4;
  if (l != 0) {
    source += '=' * (4 - l);
  }
  return utf8.decode(base64Decode(source));
}

Future<String?> getSingPath() async {
  if (Platform.isMacOS) {
    return await BcoreDesktopPlatform.instance.getSingPath();
  }
  return File(Platform.resolvedExecutable).parent.path;
}
