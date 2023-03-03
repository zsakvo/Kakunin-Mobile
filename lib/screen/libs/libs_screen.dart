import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LibsView extends StatefulHookConsumerWidget {
  const LibsView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LibsViewState();
}

class _LibsViewState extends ConsumerState<LibsView> {
  @override
  Widget build(BuildContext context) {
    Future<List<String>> getLicenseFiles() async {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      return manifestMap.keys
          .where((element) => element.contains("licenses"))
          .map((e) => e.replaceAll("assets/licenses/", ""))
          .toList();
    }

    final licensesFuture = useFuture<List<String>>(useMemoized(() => getLicenseFiles()), initialData: []);
    // useEffect(() {
    //   final licenses = licensesFuture.data;
    //   if (licenses != null) {
    //     Log.e(licenses);
    //   }
    //   return null;
    // }, [licensesFuture.data]);
    return Scaffold(
      appBar: AppBar(
        title: const Text("第三方声明"),
        elevation: 4,
      ),
      body: ListView.separated(
        itemBuilder: (context, index) {
          String item = licensesFuture.data![index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            title: Text(
              item,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              // Log.e(item);
              GoRouter.of(context).push("/lib_detail", extra: item);
            },
          );
        },
        itemCount: licensesFuture.data!.length,
        separatorBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            height: 0.3,
            child: Divider(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              thickness: 0.3,
            ),
          );
        },
      ),
    );
  }
}
