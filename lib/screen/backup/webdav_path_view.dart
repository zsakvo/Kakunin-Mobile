import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:googleapis/content/v2_1.dart';
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
    useEffect(() {
      final url = spInstance.getString("davUrl")!;
      final account = spInstance.getString("davAccount")!;
      final password = spInstance.getString("davPassword")!;
      client = newClient(
        url,
        user: account,
        password: password,
        debug: false,
      )..setHeaders({'accept-charset': 'utf-8'});
      return null;
    }, []);
    final path = useState("/");
    final requestFiles = useMemoized(() async {
      try {
        var fileList = await client.readDir(path.value);
        var list = fileList.where((e) => e.isDir!).toList();
        if (path.value.isEmpty || path.value != "/") {
          var l = path.value.split("/");
          l.removeRange(l.length - 2, l.length - 1);
          var p = l.join("/");
          list.insert(0, File(isDir: true, path: p, name: ".."));
        }
        return list;
      } catch (e) {
        Log.e(e, "出错啦");
        showErrorSnackBar("连接失败，请检查您填写的参数");
        return [];
      }
    }, [path.value]);
    var fileList = useFuture(requestFiles, initialData: []);
    return Scaffold(
      appBar: AppBar(
        title: const Text("存储位置"),
        elevation: 4,
        actions: [
          IconButton(
              onPressed: () {
                spInstance.setString("davPath", path.value);
                context.pop();
              },
              icon: const Icon(Icons.done))
        ],
      ),
      body: Container(
          padding: const EdgeInsets.only(top: 8),
          child: ListView.separated(
              itemBuilder: (context, index) {
                File file = fileList.data![index];
                return ListTile(
                  leading: const Icon(Icons.folder),
                  horizontalTitleGap: 0,
                  title: Text(file.name!),
                  onTap: () async {
                    path.value = file.path!;
                  },
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox.shrink();
              },
              itemCount: fileList.data!.length)),
    );
  }
}
