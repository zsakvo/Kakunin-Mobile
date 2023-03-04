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
  final titleStyle = const TextStyle(
    fontSize: 20,
  );
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
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Text(
                    "帐户",
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                ListTile(
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
                          "登录账户",
                          style: titleStyle,
                        ),
                        subtitle: Text(
                          "可能需要你有可靠的网络条件",
                          style: subTitleStyle,
                        ),
                        onTap: () async {
                          ref.read(cloudAccountProvider.notifier).login(CloudAccountType.Google, handle: true);
                        },
                      ),
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Text(
                    "云端",
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                  title: Text(
                    "备份数据",
                    style: titleStyle,
                  ),
                  subtitle: Text(
                    "上云有风险，隐私自己管 :_)",
                    style: subTitleStyle,
                  ),
                  onTap: () async {
                    ref.read(cloudAccountProvider.notifier).backUp();
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                  title: Text(
                    "恢复数据",
                    style: titleStyle,
                  ),
                  subtitle: Text(
                    cloudAccount.gFile == null
                        ? "暂未找到备份文件"
                        : "文件大小：${Parse.formatFileSize(cloudAccount.gFile!.size)}\n修改时间：${cloudAccount.gFile!.modifiedTime!.toLocal()}",
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
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Text(
                    "本地",
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                  title: Text(
                    "导出备份",
                    style: titleStyle,
                  ),
                  subtitle: Text(
                    "导出明文数据到 /sdcard/Download/kakunin.otp",
                    style: subTitleStyle,
                  ),
                  onTap: () async {
                    ref.read(cloudAccountProvider.notifier).backUp();
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                  title: Text(
                    "导入备份文件",
                    style: titleStyle,
                  ),
                  subtitle: Text(
                    "暂时只支持应用本身的导出数据",
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
                    "本地导出的数据是明文的，所以请您自行保管好备份文件，以免引起不必要的风险和损失",
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
          title: const Text("云备份账户"),
          content: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 12),
            child: Wrap(
              children: [
                ListTile(
                  dense: true,
                  title: const Text(
                    "更换帐号",
                    style: TextStyle(fontSize: 16),
                  ),
                  onTap: () {},
                ),
                ListTile(
                  dense: true,
                  title: const Text(
                    "登出",
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
