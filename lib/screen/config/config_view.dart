// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakunin/main.dart';
import 'package:kakunin/utils/i18n.dart';
import 'package:kakunin/utils/log.dart';
import 'package:kakunin/utils/snackbar.dart';
import 'package:local_auth/local_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import 'components/color.dart';

class ConfigView extends StatefulHookConsumerWidget {
  const ConfigView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ConfigViewState();
}

class _ConfigViewState extends ConsumerState<ConfigView> {
  final LocalAuthentication auth = LocalAuthentication();
  final titleStyle = const TextStyle(fontSize: 20, fontWeight: FontWeight.normal);
  final subTitleStyle = const TextStyle(fontSize: 14);
  checkAuth() async {
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    return canAuthenticateWithBiometrics || await auth.isDeviceSupported();
  }

  @override
  Widget build(BuildContext context) {
    final monetEnabled = ref.watch(monetEnableProvider);
    final needAuth = useState(spInstance.getBool("auth") ?? false);
    useEffect(() {
      spInstance.setBool("auth", needAuth.value);
      return null;
    }, [needAuth.value]);
    // final monetSupport = ref.watch(monetEnableProvider);
    return Scaffold(
        appBar: AppBar(
          title: Transform.translate(offset: const Offset(0, -2), child: Text("Settings".i18n)),
          elevation: 4,
        ),
        body: CustomScrollView(
          slivers: [
            SliverList(
                delegate: SliverChildListDelegate([
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Text(
                  "Appearance".i18n,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                title: Text("Dynamic Color".i18n, style: titleStyle),
                onTap: () {
                  if (!supportMonet) return;
                  ref.read(monetEnableProvider.notifier).state = !monetEnabled;
                  spInstance.setBool("dynamicColor", !monetEnabled);
                },
                subtitle: Text(
                  "Follow System Desktop for Theme Color".i18n,
                  style: subTitleStyle,
                ),
                trailing: Switch(
                  value: monetEnabled,
                  onChanged: (value) {
                    if (!supportMonet) return;
                    ref.read(monetEnableProvider.notifier).state = !monetEnabled;
                    spInstance.setBool("dynamicColor", !monetEnabled);
                  },
                  // onChanged: (value) => setSpBool("dynamicColor", !value, dynamicColor),
                ),
              ),
              monetEnabled
                  ? const SizedBox.shrink()
                  : ListTile(
                      contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                      title: Text("Select Color".i18n, style: titleStyle),
                      onTap: () {
                        final bakColor = ref.read(colorThemeProvider.notifier).state;
                        final colorSeed = Color(spInstance.getInt("colorSeed") ?? 4294198070);
                        openMainColorPicker(context, colorSeed, (color) {
                          ref.read(colorThemeProvider.notifier).state = color! as MaterialColor;
                        }, () {
                          spInstance.setInt("colorSeed", ref.read(colorThemeProvider.notifier).state.value);
                          GoRouter.of(context).pop();
                        }, () {
                          ref.read(colorThemeProvider.notifier).state = bakColor;
                          GoRouter.of(context).pop();
                        });
                      },
                      subtitle: Text(
                        "Manually Select a Color as Seed".i18n,
                        style: subTitleStyle,
                      ),
                    ),
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Text(
                  "Data".i18n,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                title: Text("Security Authentication".i18n, style: titleStyle),
                subtitle: Text(
                  "Perform Security Verification on Startup".i18n,
                  style: subTitleStyle,
                ),
                trailing: Switch(
                  value: needAuth.value,
                  onChanged: (value) async {
                    try {
                      final bool didAuthenticate = await auth.authenticate(localizedReason: '请验证您的身份信息');
                      if (didAuthenticate) {
                        needAuth.value = !needAuth.value;
                      }
                    } on PlatformException {
                      showErrorSnackBar("System has not registered any authentication method".i18n);
                    }
                  },
                  // onChanged: (value) => setSpBool("dynamicColor", !value, dynamicColor),
                ),
                onTap: () async {
                  try {
                    final bool didAuthenticate = await auth.authenticate(localizedReason: '请验证您的身份信息');
                    if (didAuthenticate) {
                      needAuth.value = !needAuth.value;
                    }
                  } on PlatformException {
                    showErrorSnackBar("System has not registered any authentication method".i18n);
                  }
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                title: Text("Backup and Restore".i18n, style: titleStyle),
                subtitle: Text(
                  "Data Cloud Backup to Reduce Risk of Accidental Loss".i18n,
                  style: subTitleStyle,
                ),
                onTap: () {
                  GoRouter.of(context).push("/backup");
                },
              ),
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Text(
                  "About".i18n,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                title: Text("Open Source License".i18n, style: titleStyle),
                subtitle: Text(
                  "No Them, No Me".i18n,
                  style: subTitleStyle,
                ),
                onTap: () {
                  GoRouter.of(context).push("/libs");
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                title: Text("Project Homepage".i18n, style: titleStyle),
                subtitle: Text(
                  "View Source Code and Buy Me a Coffee".i18n,
                  style: subTitleStyle,
                ),
                onTap: () async {
                  try {
                    await launchUrl(
                      Uri.parse("https://github.com/zsakvo/Kakunin-Mobile"),
                      mode: LaunchMode.externalApplication,
                    );
                  } catch (err) {
                    Log.e(err);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Link access failed".i18n),
                      backgroundColor: Theme.of(context).colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                    ));
                  }
                },
              )
            ]))
          ],
        ));
  }
}
