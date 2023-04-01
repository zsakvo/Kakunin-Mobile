import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakunin/main.dart';
import 'package:kakunin/utils/log.dart';
import 'package:kakunin/utils/snackbar.dart';
import 'package:webdav_client/webdav_client.dart';

class WebDavPathView extends StatefulHookConsumerWidget {
  const WebDavPathView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WebDavPathViewState();
}

class _WebDavPathViewState extends ConsumerState<WebDavPathView> {
  late Client client;
  @override
  Widget build(BuildContext context) {
    final fileList = useFuture<List<File>>(useMemoized(() async {
      final url = spInstance.getString("davUrl")!;
      final account = spInstance.getString("davAccount")!;
      final password = spInstance.getString("davPassword")!;
      client = newClient(
        url,
        user: account,
        password: password,
        debug: false,
      )..setHeaders({'accept-charset': 'utf-8'});
      try {
        var fileList = await client.readDir('/');
        return fileList.where((e) => e.isDir!).toList();
      } catch (e) {
        Log.e(e, "出错啦");
        showErrorSnackBar("连接失败，请检查您填写的参数");
        return [];
      }
    }), initialData: []);
    return Scaffold(
      appBar: AppBar(
        title: const Text("存储位置"),
        elevation: 4,
      ),
      body: Container(
          child: ListView.separated(
              itemBuilder: (context, index) {
                File file = fileList.data![index];
                return ListTile(
                  leading: const Icon(Icons.folder),
                  horizontalTitleGap: 0,
                  title: Text(file.name!),
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox.shrink();
              },
              itemCount: fileList.data!.length)),
    );
  }
}
