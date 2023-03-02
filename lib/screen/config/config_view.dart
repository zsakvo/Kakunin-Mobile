import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakunin/main.dart';
import 'package:kakunin/utils/log.dart';
import 'package:url_launcher/url_launcher.dart';

import 'components/color.dart';

class ConfigView extends StatefulHookConsumerWidget {
  const ConfigView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ConfigViewState();
}

class _ConfigViewState extends ConsumerState<ConfigView> {
  final titleStyle = const TextStyle(
    fontSize: 20,
  );
  final subTitleStyle = const TextStyle(fontSize: 14);
  @override
  Widget build(BuildContext context) {
    final monetEnabled = ref.watch(monetEnableProvider);
    // final monetSupport = ref.watch(monetEnableProvider);
    return Scaffold(
        appBar: AppBar(
          title: Transform.translate(offset: const Offset(0, -2), child: const Text("设置")),
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
                  "外观",
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                title: Text("动态取色", style: titleStyle),
                onTap: () {
                  if (!supportMonet) return;
                  ref.read(monetEnableProvider.notifier).state = !monetEnabled;
                  spInstance.setBool("dynamicColor", !monetEnabled);
                },
                subtitle: Text(
                  "跟随系统桌面自动获取主题色",
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
                      title: Text("选取颜色", style: titleStyle),
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
                        "手动选择一个色彩，这将作为种子被应用",
                        style: subTitleStyle,
                      ),
                    ),
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Text(
                  "关于",
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                title: Text("开源许可", style: titleStyle),
                subtitle: Text(
                  "没有他们就没有我 :)",
                  style: subTitleStyle,
                ),
                onTap: () {
                  GoRouter.of(context).push("/libs");
                },
              ),
              ListTile(
                contentPadding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
                title: Text("项目主页", style: titleStyle),
                subtitle: Text(
                  "来看看不知所云的源代码，或者请我喝咖啡？",
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
                      content: const Text("链接访问失败"),
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
