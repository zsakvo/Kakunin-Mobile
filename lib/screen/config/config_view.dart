import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakunin/main.dart';

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
                  spInstance.setBool("dynamicColor", monetEnabled);
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
                    spInstance.setBool("dynamicColor", monetEnabled);
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
                        final colorSeed = ref.read(colorThemeProvider.notifier).state;
                        openMainColorPicker(context, colorSeed, (color) {
                          ref.read(colorThemeProvider.notifier).state = color! as MaterialColor;
                        }, () {
                          spInstance.setInt("colorSeed", ref.read(colorThemeProvider.notifier).state.value);
                          GoRouter.of(context).pop();
                        }, () {
                          ref.read(colorThemeProvider.notifier).state = colorSeed;
                          GoRouter.of(context).pop();
                        });
                      },
                      subtitle: Text(
                        "手动选择一个色彩，这将作为种子被应用",
                        style: subTitleStyle,
                      ),
                    ),
            ]))
          ],
        ));
  }
}
