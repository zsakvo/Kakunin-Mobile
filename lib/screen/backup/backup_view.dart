// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakunin/main.dart';
import 'package:kakunin/provider.dart';
import 'package:kakunin/utils/cloud.dart';
import 'package:kakunin/utils/i18n.dart';
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
    // final isSignedIn = useState(false);
    // final userInfo = useState(json.decode(spInstance.getString("googleAccount") ?? "{}"));
    final cloudAccount = ref.watch(cloudAccountProvider);
    final accountType = useState(spInstance.getInt("accountType") ?? 0);
    useEffect(() {
      spInstance.setInt("accountType", accountType.value);
      return null;
    }, [accountType.value]);
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
        title: Text("Backup and Restore".i18n),
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
                    "Account".i18n,
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                  title: Text(
                    "Cloud Connection Type".i18n,
                    style: titleStyle,
                  ),
                  subtitle: Text(
                    "${"Current Storage Location".i18n} ${CloudAccountType.values[accountType.value].name}",
                    style: subTitleStyle,
                  ),
                  onTap: () async {
                    // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    //   content: Text("说了只支持Google Drive"),
                    //   behavior: SnackBarBehavior.floating,
                    // ));
                    switchCloud(accountType);
                  },
                ),
                cloudAccount.isLogin
                    ? (() {
                        switch (accountType.value) {
                          case 0:
                            return ListTile(
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
                            );
                          case 1:
                            return ListTile(
                              contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                              // ignore: prefer_const_constructors
                              title: Text(
                                "${"Current Usage".i18n} WebDAV",
                              ),
                              subtitle: Text(
                                "${cloudAccount.davUrl}",
                                style: subTitleStyle,
                              ),
                              onTap: () {
                                openDialog();
                              },
                            );
                          default:
                            return const SizedBox.shrink();
                        }
                      })()
                    : ListTile(
                        contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                        title: Text(
                          "Login Account".i18n,
                          style: titleStyle,
                        ),
                        subtitle: Text(
                          "You may need a reliable network connection.".i18n,
                          style: subTitleStyle,
                        ),
                        onTap: () async {
                          ref
                              .read(cloudAccountProvider.notifier)
                              .login(CloudAccountType.values[accountType.value], handle: true);
                        },
                      ),
                accountType.value == 1
                    ? ListTile(
                        contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                        title: Text(
                          "Current Storage Location".i18n,
                          style: titleStyle,
                        ),
                        subtitle: Text(
                          // "设定您在WebDav上的默认备份路径",
                          "Current storage path".i18n + (cloudAccount.davPath ?? "/"),
                          style: subTitleStyle,
                        ),
                        onTap: () async {
                          ref.read(cloudAccountProvider.notifier).setWebDavPath(context);
                        },
                      )
                    : const SizedBox.shrink(),
                const Divider(
                  indent: 16,
                  endIndent: 16,
                ),
                ListTile(
                  leading: const Icon(Icons.help_outline_outlined),
                  horizontalTitleGap: 0,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  subtitle: Text(
                    "Your data will be encrypted using RSA before being stored in the cloud. However, the corresponding public and private keys can be found in the source code of this application. Please be cautious and ensure proper backup of your data."
                        .i18n,
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
                            "Cloud".i18n,
                            style: TextStyle(color: Theme.of(context).colorScheme.primary),
                          ),
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                          title: Text(
                            "Backup Data".i18n,
                            style: titleStyle,
                          ),
                          subtitle: Text(
                            "Uploading data to the cloud carries risks. Please manage your privacy.".i18n,
                            style: subTitleStyle,
                          ),
                          onTap: () async {
                            ref.read(cloudAccountProvider.notifier).backUp();
                          },
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                          title: Text(
                            "Restore Data".i18n,
                            style: titleStyle,
                          ),
                          subtitle: Text(
                            (() {
                              switch (accountType.value) {
                                case 0:
                                  return cloudAccount.gFile == null
                                      ? "Backup file not found".i18n
                                      : "${"File Size".i18n}：${Parse.formatFileSize(cloudAccount.gFile!.size)}\n${"Modification Time".i18n}：${cloudAccount.gFile!.modifiedTime!.toLocal()}";
                                default:
                                  return cloudAccount.davFileTime == null
                                      ? "Backup file not found".i18n
                                      : "${"File Size".i18n}：${cloudAccount.davFileSize}\n${"Modification Time".i18n}：${cloudAccount.davFileTime}";
                              }
                            })(),
                            style: subTitleStyle,
                          ),
                          onTap: () async {
                            ref.read(cloudAccountProvider.notifier).restore();
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
                            CloudUtil.getHint(CloudAccountType.values[accountType.value]),
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
                    "Local".i18n,
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                  title: Text(
                    "Export Backup".i18n,
                    style: titleStyle,
                  ),
                  subtitle: Text(
                    cloudAccount.localDir != null
                        ? "${"Currently backed up in".i18n} ${cloudAccount.localDir}\n${"Long press to switch output directory".i18n}"
                        : "Backup location not selected yet".i18n,
                    style: subTitleStyle,
                  ),
                  onTap: () async {
                    ref.read(cloudAccountProvider.notifier).backUpLocal();
                  },
                  onLongPress: () {
                    ref.read(cloudAccountProvider.notifier).resetLocalDir();
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                  title: Text(
                    "Import backup file".i18n,
                    style: titleStyle,
                  ),
                  subtitle: Text(
                    "Only supports exporting data from the application itself".i18n,
                    style: subTitleStyle,
                  ),
                  onTap: () async {
                    ref.read(cloudAccountProvider.notifier).restoreLocal();
                  },
                ),
                // const Divider(
                //   indent: 16,
                //   endIndent: 16,
                // ),
                // ListTile(
                //   leading: const Icon(Icons.help_outline_outlined),
                //   horizontalTitleGap: 0,
                //   contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                //   subtitle: Text(
                //     "Only supports exporting data from the application itself".i18n,
                //     textAlign: TextAlign.justify,
                //     style: TextStyle(
                //       color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                //       fontSize: 13,
                //     ),
                //   ),
                // ),
              ],
            ),
          )
        ],
      )),
    );
  }

  void switchCloud(ValueNotifier<int> accountType) {
    int val = accountType.value;
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: const EdgeInsets.all(0.0),
              title: Text("Cloud backup location".i18n),
              actions: [
                TextButton(
                    onPressed: () {
                      GoRouter.of(context).pop();
                    },
                    child: Text("Cancel".i18n)),
                TextButton(
                    onPressed: () {
                      ref.read(cloudAccountProvider.notifier).checkLogin(CloudAccountType.values[val]);
                      accountType.value = val;
                      GoRouter.of(context).pop();
                    },
                    child: Text("OK".i18n))
              ],
              content: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                child: Wrap(
                  children: [
                    RadioListTile(
                      value: CloudAccountType.Google.index,
                      groupValue: val,
                      title: const Text("Google Drive"),
                      onChanged: (value) {
                        setState(() {
                          val = value!;
                        });
                      },
                    ),
                    RadioListTile(
                      value: CloudAccountType.WebDav.index,
                      groupValue: val,
                      title: const Text("WebDav"),
                      onChanged: (value) {
                        setState(() {
                          val = value!;
                        });
                      },
                    ),
                    // RadioListTile(
                    //   value: CloudAccountType.DropBox.index,
                    //   groupValue: val,
                    //   title: const Text("DropBox"),
                    //   onChanged: (value) {
                    //     return;
                    //     setState(() {
                    //       val = value!;
                    //     });
                    //   },
                    // ),
                    // RadioListTile(
                    //   value: CloudAccountType.AliYun.index,
                    //   groupValue: val,
                    //   title: const Text("AliYun"),
                    //   onChanged: (value) {
                    //     return;
                    //     setState(() {
                    //       val = value!;
                    //     });
                    //   },
                    // )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void openDialog() {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(6.0),
          title: Text("Cloud backup account".i18n),
          content: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 12),
            child: Wrap(
              children: [
                ListTile(
                  dense: true,
                  title: Text(
                    "Change account".i18n,
                    style: const TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    GoRouter.of(context).pop();
                    ref.read(cloudAccountProvider.notifier).logout();
                    ref.read(cloudAccountProvider.notifier).login(CloudAccountType.Google, handle: true);
                  },
                ),
                ListTile(
                  dense: true,
                  title: Text(
                    "Logout".i18n,
                    style: const TextStyle(fontSize: 16),
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
