import 'dart:convert';
import 'dart:typed_data';

import 'package:base32/base32.dart';
import 'package:kakunin/data/models/verification_item.dart';
import 'package:kakunin/data/protos/google_auth.pb.dart';

class GoogleAuth {
  final String originStr;
  GoogleAuth({required this.originStr});

  List<VerificationItem> decode() {
    final data = Uri.parse(originStr).queryParameters["data"];
    final items = <VerificationItem>[];
    if (data != null) {
      var buffer = base64.decode(data);
      var decode = MigrationPayload.fromBuffer(buffer);
      for (var otp in decode.otpParameters) {
        late String type;
        switch (otp.type.toString()) {
          case "OTP_HOTP":
            type = "HOTP";
            break;
          case "OTP_TOTP":
            type = "TOTP";
            break;
        }
        // Google的貌似只支持 SHA1，所以直接写死
        items.add(VerificationItem(
            type: type,
            name: otp.name.toString(),
            vendor: otp.issuer.toString(),
            key: base32.encode(Uint8List.fromList(otp.secret)),
            length: 6,
            sha: "SHA1",
            time: 30,
            counter: otp.counter.toInt()));
      }
    }
    return items;
  }
}
