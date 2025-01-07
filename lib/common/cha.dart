import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';

class Decryptor {
  static String decryptChaCha20(Map<String, dynamic> encryptedData, String savedKey) {
    try {
      final keyBytes = base64.decode(savedKey);
      final nonceBytes = base64.decode(encryptedData['nonce']);
      final tagBytes = base64.decode(encryptedData['tag']);
      final cipherTextBytes = base64.decode(encryptedData['ciphertext']);

      final params = ParametersWithIV(
        KeyParameter(Uint8List.fromList(keyBytes)),
        Uint8List.fromList(nonceBytes),
      );

      final cipher = ChaCha20Poly1305(
        ChaCha7539Engine(),
        Poly1305()
      )..init(false, params);

      final combined = Uint8List(cipherTextBytes.length + tagBytes.length)
        ..setAll(0, cipherTextBytes)
        ..setAll(cipherTextBytes.length, tagBytes);

      final decrypted = cipher.process(combined);

      return utf8.decode(decrypted);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }
}