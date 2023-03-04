import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

AsyncSnapshot<T> useMemorizedFuture<T>(Future<T> Function() create) {
  final future = useMemoized(create, const []);
  return useFuture(future);
}
