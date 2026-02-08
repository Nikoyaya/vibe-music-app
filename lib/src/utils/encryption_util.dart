import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vibe_music_app/src/utils/app_logger.dart';

/// 加密工具类
class EncryptionUtil {
  /// 公钥
  static String get publicKey {
    return dotenv.env['RSA_PUBLIC_KEY'] ?? '';
  }

  /// 使用RSA公钥加密字符串
  /// [plainText]: 要加密的明文
  /// [return]: 加密后的密文（Base64编码）
  static String rsaEncrypt(String plainText) {
    try {
      // 获取RSA公钥
      final rsaPublicKeyStr = publicKey;
      if (rsaPublicKeyStr.isEmpty) {
        throw Exception('RSA公钥为空');
      }

      // 创建RSA公钥
      final rsaPublicKey = encrypt.RSAKeyParser().parse(rsaPublicKeyStr);

      // 创建加密器
      final encrypter =
          encrypt.Encrypter(encrypt.RSA(publicKey: rsaPublicKey as dynamic));

      // 加密数据
      final encrypted = encrypter.encrypt(plainText);

      // 返回Base64编码的密文
      return encrypted.base64;
    } catch (e) {
      // 加密失败时返回明文（作为降级方案）
      AppLogger().d('RSA加密失败: $e');
      return plainText;
    }
  }
}
