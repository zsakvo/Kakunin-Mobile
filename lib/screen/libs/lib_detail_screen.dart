import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LibDetailView extends HookConsumerWidget {
  const LibDetailView({super.key, required this.lib});
  final String lib;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<String> getLicenseString() async {
      return await rootBundle.loadString("assets/licenses/$lib");
    }

    final licenseString = useFuture(useMemoized(() => getLicenseString()), initialData: "");
    return Scaffold(
      appBar: AppBar(
        title: Text(
          lib,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 4,
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          child: Text(
            licenseString.data!,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      )),
    );
  }
}
