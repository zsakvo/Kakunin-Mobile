// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakunin/hooks/use_memorized_future.dart';
import 'package:kakunin/main.dart';
import 'package:kakunin/provider.dart';
import 'package:kakunin/utils/cloud.dart';
import 'package:kakunin/utils/encode.dart';
import 'package:kakunin/utils/log.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:kakunin/utils/parse.dart';

class BackupView extends StatefulHookConsumerWidget {
  const BackupView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BackupViewState();
}

class _BackupViewState extends ConsumerState<BackupView> {
  final titleStyle = const TextStyle(fontSize: 20, fontWeight: FontWeight.normal);
  final subTitleStyle = const TextStyle(fontSize: 14);
  // final GoogleSignIn googleSignIn = GoogleSignIn(
  //   scopes: [
  //     'email',
  //     // 'https://www.googleapis.com/auth/drive.appdata',
  //     DriveApi.driveFileScope
  //     // 'https://www.googleapis.com/auth/drive.appfolder'
  //   ],
  // );
  @override
  Widget build(BuildContext context) {
    final isSignedIn = useState(false);
    final userInfo = useState(json.decode(spInstance.getString("googleAccount") ?? "{}"));
    final cloudAccount = ref.watch(cloudAccountProvider);
    // useEffect(() {
    //   if (isSignedIn.value) {
    //     useMemorizedFuture(() async {
    //       final _about = await driveApi!.about.get($fields: "storageQuota");
    //       final _quota = _about.storageQuota!;
    //       // return _quota;
    //       userInfo.value = {
    //         "email": googleAccount!.email,
    //         "total": Parse.formatFileSize(_quota.limit!),
    //         "usage": Parse.formatFileSize(_quota.usage!)
    //       };
    //     });
    //   }
    //   return null;
    // }, [isSignedIn.value]);
    return Scaffold(
      appBar: AppBar(
        title: const Text("???????????????"),
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
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Text(
                    "??????",
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                  title: Text(
                    "???????????????",
                    style: titleStyle,
                  ),
                  subtitle: Text(
                    "???????????????Google Drive",
                    style: subTitleStyle,
                  ),
                  onTap: () async {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("???????????????Google Drive"),
                      behavior: SnackBarBehavior.floating,
                    ));
                  },
                ),
                cloudAccount.isLogin
                    ? ListTile(
                        contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                        title: Text(
                          cloudAccount.user!,
                        ),
                        subtitle: Text(
                          "${cloudAccount.usage} / ${cloudAccount.total}",
                          style: subTitleStyle,
                        ),
                        onTap: () {
                          openDialog();
                        },
                      )
                    : ListTile(
                        contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                        title: Text(
                          "????????????",
                          style: titleStyle,
                        ),
                        subtitle: Text(
                          "???????????????????????????????????????",
                          style: subTitleStyle,
                        ),
                        onTap: () async {
                          ref.read(cloudAccountProvider.notifier).login(CloudAccountType.Google, handle: true);
                        },
                      ),
                const Divider(
                  indent: 16,
                  endIndent: 16,
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline_outlined),
                  horizontalTitleGap: 0,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  subtitle: Text(
                    "?????????????????????RSA?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????",
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ),
                ...cloudAccount.isLogin
                    ? [
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          child: Text(
                            "??????",
                            style: TextStyle(color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                          title: Text(
                            "????????????",
                            style: titleStyle,
                          ),
                          subtitle: Text(
                            "????????????????????????????????? :_)",
                            style: subTitleStyle,
                          ),
                          onTap: () async {
                            ref.read(cloudAccountProvider.notifier).backUp();
                          },
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                          title: Text(
                            "????????????",
                            style: titleStyle,
                          ),
                          subtitle: Text(
                            cloudAccount.gFile == null
                                ? "????????????????????????"
                                : "???????????????${Parse.formatFileSize(cloudAccount.gFile!.size)}\n???????????????${cloudAccount.gFile!.modifiedTime!.toLocal()}",
                            style: subTitleStyle,
                          ),
                          onTap: () async {
                            ref.read(cloudAccountProvider.notifier).restoreGoogle();
                          },
                        ),
                        const Divider(
                          indent: 16,
                          endIndent: 16,
                        ),
                        ListTile(
                          leading: const Icon(Icons.help_outline_outlined),
                          horizontalTitleGap: 0,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          subtitle: Text(
                            CloudUtil.getHint(CloudAccountType.Google),
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ]
                    : [const SizedBox.shrink()],
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Text(
                    "??????",
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                  title: Text(
                    "????????????",
                    style: titleStyle,
                  ),
                  subtitle: Text(
                    cloudAccount.localDir != null ? "???????????????${cloudAccount.localDir}" : "????????????????????????",
                    style: subTitleStyle,
                  ),
                  onTap: () async {
                    ref.read(cloudAccountProvider.notifier).backUpLocal();
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                  title: Text(
                    "??????????????????",
                    style: titleStyle,
                  ),
                  subtitle: Text(
                    "??????????????????????????????????????????",
                    style: subTitleStyle,
                  ),
                  onTap: () async {
                    ref.read(cloudAccountProvider.notifier).restoreLocal();
                  },
                ),
                const Divider(
                  indent: 16,
                  endIndent: 16,
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline_outlined),
                  horizontalTitleGap: 0,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  subtitle: Text(
                    "?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????",
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      )),
    );
  }

  void openDialog() {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(6.0),
          title: const Text("???????????????"),
          content: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 12),
            child: Wrap(
              children: [
                ListTile(
                  dense: true,
                  title: const Text(
                    "????????????",
                    style: TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    GoRouter.of(context).pop();
                    ref.read(cloudAccountProvider.notifier).logout();
                    ref.read(cloudAccountProvider.notifier).login(CloudAccountType.Google, handle: true);
                  },
                ),
                ListTile(
                  dense: true,
                  title: const Text(
                    "??????",
                    style: TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    GoRouter.of(context).pop();
                    ref.read(cloudAccountProvider.notifier).logout();
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
