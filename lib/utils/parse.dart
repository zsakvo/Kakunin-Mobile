import 'package:kakunin/data/models/verification_item.dart';

class Parse {
  static VerificationItem? uri(String uriStr) {
    final uri = Uri.parse(uriStr);
    if (uri.scheme != "otpauth") return null;
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
    return item;
  }

  static timeValue(time, allTime) {
    return (time / allTime) * 1.00;
  }
}
