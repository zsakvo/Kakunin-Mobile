import 'package:flutter/material.dart';
import 'package:kakunin/router.dart';

showErrorSnackBar(String content) {
  final context = NavigationService.navigatorKey.currentContext!;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      content,
      style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
    ),
    behavior: SnackBarBehavior.floating,
    backgroundColor: Theme.of(context).colorScheme.errorContainer,
  ));
}

showSnackBar(String content) {
  ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(SnackBar(
    content: Text(content),
    behavior: SnackBarBehavior.floating,
  ));
}
