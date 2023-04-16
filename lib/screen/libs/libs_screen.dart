import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakunin/utils/i18n.dart';

const libs = [
  'cupertino_icons',
  'go_router',
  'otp',
  'flutter_hooks',
  'isar',
  'isar_flutter_libs',
  'logger',
  'uuid',
  'timezone',
  'dynamic_color',
  'hooks_riverpod',
  'riverpod_annotation',
  'shared_preferences',
  'equatable',
  'clipboard',
  'mobile_scanner',
  'image_picker',
  'flutter_material_color_picker',
  'base32',
  'url_launcher',
  'protobuf',
  'local_auth',
  'flutter_exit_app',
  'googleapis',
  'google_sign_in',
  'firebase_core',
  'extension_google_sign_in_as_googleapis_auth',
  'fast_rsa',
  'path_provider',
  'file_picker',
  'webdav_client',
  'i18n_extension',
  'flutter_localizations',
  'http',
  'html_unescape'
];

class LibsView extends StatefulHookConsumerWidget {
  const LibsView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LibsViewState();
}

class _LibsViewState extends ConsumerState<LibsView> {
  @override
  Widget build(BuildContext context) {
    // Future<List<String>> getLicenseFiles() async {
    //   final manifestContent = await rootBundle.loadString('AssetManifest.json');
    //   final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    //   return manifestMap.keys
    //       .where((element) => element.contains("licenses"))
    //       .map((e) => e.replaceAll("assets/licenses/", ""))
    //       .toList();
    // }

    // final licensesFuture = useFuture<List<String>>(useMemoized(() => getLicenseFiles()), initialData: []);
    // useEffect(() {
    //   final licenses = licensesFuture.data;
    //   if (licenses != null) {
    //     Log.e(licenses);
    //   }
    //   return null;
    // }, [licensesFuture.data]);
    return Scaffold(
      appBar: AppBar(
        title: Text("Third Party Disclaimer".i18n),
        elevation: 4,
      ),
      body: ListView.separated(
        itemBuilder: (context, index) {
          String item = libs[index];
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
        itemCount: libs.length,
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
