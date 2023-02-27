import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:kakunin/data/models/verification_item.dart';

import 'package:timezone/timezone.dart' as timezone;

import 'components/list_item.dart';

final pacificTimeZone = timezone.getLocation('Asia/Shanghai');

final verificationItemsProvider = StateNotifierProvider<VerificationItemsNotifier, List<ListItemView>>((ref) {
  return VerificationItemsNotifier(ref);
});

class VerificationItemsNotifier extends StateNotifier<List<ListItemView>> {
  final Isar _isar = Isar.getInstance()!;
  late Timer _timer;
  final Ref ref;
  VerificationItemsNotifier(
    this.ref,
  ) : super([]) {
    refresh();
  }
  refresh() {
    state = _isar.verificationItems
        .where()
        .findAllSync()
        .map((e) => ListItemView(
              item: e,
            ))
        .toList();
  }

  insertItem(VerificationItem item) {
    state = [
      ListItemView(
        item: item,
      ),
      ...state
    ];
    _isar.writeTxnSync(() {
      _isar.verificationItems.putSync(item);
    });
  }

  updateHotp(int id, int used) {
    _isar.writeTxnSync(() {
      final item = _isar.verificationItems.getSync(id);
      item!.used = used;
      _isar.verificationItems.putSync(item);
    });
  }

  deleteItem(VerificationItem item) {
    _isar.writeTxnSync(() {
      _isar.verificationItems.filter().idEqualTo(item.id).deleteAllSync();
    });
    state = state.where((element) => element.item.id != item.id).toList();
    // refresh();
  }
}

// class VerificationShowItem {
//   final double timeLeft;
//   final String token;
//   final VerificationItem vItem;
//   VerificationShowItem({required this.timeLeft, required this.token, required this.vItem});

//   double get progressValue => (timeLeft / vItem.time!) * 1.00;

//   String get tokenValue => (token.split("")..insert(3, " ")).join("");
// }

// var timeValueProvider = StateProvider((ref) => {});

// var tokenValueProvider = StateProvider((ref) => {});
