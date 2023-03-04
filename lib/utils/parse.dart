import 'package:kakunin/data/models/verification_item.dart';
import 'package:kakunin/utils/decode.dart';

class Parse {
  static List<VerificationItem> uri(String uriStr) {
    final uri = Uri.parse(uriStr);
    if (uri.scheme == "otpauth") {
      final type = uri.host.toUpperCase();
      final name = uri.path.replaceAll("/", "");
      final querMaps = uri.queryParameters;
      final key = querMaps["secret"] ?? "";
      final vendor = querMaps["issuer"] ?? "";
      final sha = (querMaps["algorithm"] ?? "SHA1").toUpperCase();
      final length = int.tryParse(querMaps["digits"] ?? "6");
      final time = int.tryParse(querMaps["period"] ?? "30");
      final counter = int.tryParse(querMaps["counter"] ?? "0");
      final VerificationItem item = VerificationItem(
          type: type, name: name, key: key, vendor: vendor, sha: sha, length: length, time: time, counter: counter);
      return [item];
    } else if (uri.scheme == "otpauth-migration") {
      return GoogleAuth(originStr: uriStr).decode();
    } else {
      return [];
    }
  }

  static timeValue(time, allTime) {
    return (time / allTime) * 1.00;
  }

  static String formatFileSize(dynamic bytes) {
    bytes = int.parse(bytes);
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      double kb = bytes / 1024;
      return '${kb.toStringAsFixed(2)}KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      double mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(2)}MB';
    } else {
      double gb = bytes / (1024 * 1024 * 1024);
      return '${gb.toStringAsFixed(2)}GB';
    }
  }
}
