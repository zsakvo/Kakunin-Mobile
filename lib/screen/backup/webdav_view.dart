import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakunin/utils/log.dart';
import 'package:kakunin/utils/snackbar.dart';
import 'package:webdav_client/webdav_client.dart';

class WebDavView extends StatefulHookConsumerWidget {
  const WebDavView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WebDavViewState();
}

class _WebDavViewState extends ConsumerState<WebDavView> {
  @override
  Widget build(BuildContext context) {
    final urlController = useTextEditingController();
    final userController = useTextEditingController();
    final passwordController = useTextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text("配置WebDav"),
        elevation: 4.0,
      ),
      body: SafeArea(
          child: Wrap(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
            child: TextField(
              controller: urlController,
              decoration: const InputDecoration(
                isDense: true,
                labelText: '链接地址',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
            child: TextField(
              controller: userController,
              decoration: const InputDecoration(
                isDense: true,
                labelText: '用户名',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
            child: TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                isDense: true,
                labelText: '密码',
                border: OutlineInputBorder(),
              ),
            ),
          )
        ],
      )),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          Log.e("开始登录");
          var client = newClient(
            urlController.text,
            user: userController.text,
            password: passwordController.text,
            debug: true,
          )..setHeaders({'accept-charset': 'utf-8'});
          try {
            await client.ping();
            await client.readDir('/');
          } catch (e) {
            Log.e(e, "出错啦");
            showErrorSnackBar("连接失败，请检查您填写的参数");
          }
        },
        label: const Text("登录"),
        // ignore: prefer_const_constructors
        icon: Icon(Icons.add_link_rounded),
      ),
    );
  }
}
