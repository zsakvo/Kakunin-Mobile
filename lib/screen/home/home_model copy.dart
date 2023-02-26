import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:kakunin/data/models/verification_item.dart';
import 'package:kakunin/utils/log.dart';
import 'package:otp/otp.dart';

import 'package:timezone/timezone.dart' as timezone;

final pacificTimeZone = timezone.getLocation('Asia/Shanghai');

final verificationItemsProvider = StateNotifierProvider<VerificationItemsNotifier, List<VerificationShowItem>>((ref) {
  return VerificationItemsNotifier();
});

class VerificationItemsNotifier extends StateNotifier<List<VerificationShowItem>> {
  final Isar _isar = Isar.getInstance()!;
  late Timer _timer;
  VerificationItemsNotifier() : super([]) {
    refresh();
  }
  refresh() {
    state = _isar.verificationItems.where().findAllSync().map((item) {
      late Algorithm algorithm;
      if (item.sha == "SHA1") {
        algorithm = Algorithm.SHA1;
      } else if (item.sha == "SHA256") {
        algorithm = Algorithm.SHA256;
      } else if (item.sha == "SHA512") {
        algorithm = algorithm = Algorithm.SHA512;
      }
      final now = DateTime.now();
      final date = timezone.TZDateTime.from(now, pacificTimeZone);
      String token;
      if (item.type == "TOTP") {
        token =
            OTP.generateTOTPCodeString(item.key!, date.millisecondsSinceEpoch, algorithm: algorithm, isGoogle: true);
      } else {
        token = OTP.generateHOTPCodeString(item.key!, item.counter!, isGoogle: true);
      }
      final leftTime = OTP.remainingSeconds(interval: item.time!) * 1.0;
      Log.e(leftTime, "lt");

      // token = (token.split("")..insert(3, " ")).join("");

      return VerificationShowItem(timeLeft: leftTime, token: token, vItem: item);
    }).toList();
    chronometer();
  }

  chronometer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      for (var i = 0; i < state.length; i++) {
        VerificationShowItem item = state[i];
        VerificationItem vItem = item.vItem;
        if (vItem.type == "TOTP") {
          late Algorithm algorithm;
          if (vItem.sha == "SHA1") {
            algorithm = Algorithm.SHA1;
          } else if (vItem.sha == "SHA256") {
            algorithm = Algorithm.SHA256;
          } else if (vItem.sha == "SHA512") {
            algorithm = algorithm = Algorithm.SHA512;
          }
          // final num = 100 * 1 / token.period!;
          double timeLeft;
          String token;
          if (item.timeLeft >= 1) {
            timeLeft = item.timeLeft - 1;
            token = item.token;
          } else {
            timeLeft = vItem.time! - (1 - item.timeLeft);
            final now = DateTime.now();
            final date = timezone.TZDateTime.from(now, pacificTimeZone);
            token = OTP.generateTOTPCodeString(vItem.key!, date.millisecondsSinceEpoch,
                algorithm: algorithm, isGoogle: true);
          }

          // token = (token.split("")..insert(3, " ")).join("");

          // timeValue = (timeLeft / item.timeLeft) * 100.0;

          state[i] = VerificationShowItem(token: token, timeLeft: timeLeft, vItem: vItem);
        } else {
          state[i] = item;
        }
      }
      state = [...state];
      // timer.cancel();
    });
  }

  insertItem(VerificationItem item) {
    // state = [item, ...state];
    _timer.cancel();
    _isar.writeTxnSync(() {
      _isar.verificationItems.putSync(item);
    });
    refresh();
  }

  updateHotp(VerificationShowItem item) {
    int index = state.indexOf(item);
    var token = OTP.generateHOTPCodeString(item.vItem.key!, item.vItem.used! + 1, isGoogle: true);
    var vItem = item.vItem.copyWith(used: item.vItem.used! + 1);
    var newItem = VerificationShowItem(vItem: vItem, token: token, timeLeft: 0);
    state[index] = newItem;
    _isar.writeTxnSync(() {
      _isar.verificationItems.putSync(vItem);
    });
  }

  deleteItem(VerificationShowItem item) {
    _timer.cancel();
    _isar.writeTxnSync(() {
      _isar.verificationItems.filter().idEqualTo(item.vItem.id).deleteAllSync();
    });
    refresh();
  }
}

class VerificationShowItem {
  final double timeLeft;
  final String token;
  final VerificationItem vItem;
  VerificationShowItem({required this.timeLeft, required this.token, required this.vItem});

  double get progressValue => (timeLeft / vItem.time!) * 1.00;

  String get tokenValue => (token.split("")..insert(3, " ")).join("");
}
