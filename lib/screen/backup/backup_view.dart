import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakunin/utils/log.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

class BackupView extends StatefulHookConsumerWidget {
  const BackupView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BackupViewState();
}

class _BackupViewState extends ConsumerState<BackupView> {
  final titleStyle = const TextStyle(
    fontSize: 20,
  );
  final subTitleStyle = const TextStyle(fontSize: 14);
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      // 'https://www.googleapis.com/auth/drive.appdata',
      DriveApi.driveFileScope
      // 'https://www.googleapis.com/auth/drive.appfolder'
    ],
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("备份和恢复"),
        elevation: 4,
      ),
      body: SafeArea(
          child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Wrap(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                    title: Text(
                      "云连接类型",
                      style: titleStyle,
                    ),
                    subtitle: Text(
                      "当前仅支持 Google Drive",
                      style: subTitleStyle,
                    ),
                    onTap: () async {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("说了只支持Google Drive"),
                        behavior: SnackBarBehavior.floating,
                      ));
                    },
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                  title: Text(
                    "登录账户",
                    style: titleStyle,
                  ),
                  subtitle: Text(
                    "可能需要你有可靠的网络条件",
                    style: subTitleStyle,
                  ),
                  onTap: () async {
                    try {
                      GoogleSignInAccount? account = await googleSignIn.signIn();
                      Log.e(account);
                      final ints = "Hello Kakunin".codeUnits;
                      var httpClient = (await googleSignIn.authenticatedClient())!;
                      var driveApi = DriveApi(httpClient);
                      File tmpFile = File(
                        name: "kakunin.otp",
                        description: "Kakunin应用备份",
                      );
                      Media uploadMedia = Media(Stream.value("Hello Kakunin".codeUnits), ints.length);
                      await driveApi.files.create(tmpFile, uploadMedia: uploadMedia);
                      FileList files = await driveApi.files.list(spaces: "appDataFolder");
                      files.files?.forEach((element) {
                        Log.e(element);
                      });
                      // Log.e(favorites);
                    } catch (error) {
                      Log.e(error);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(error.toString()),
                        behavior: SnackBarBehavior.floating,
                      ));
                    }
                  },
                ),
              ],
            ),
          )
        ],
      )),
    );
  }
}
