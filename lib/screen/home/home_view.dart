// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
// import 'package:go_router_flow/go_router_flow.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakunin/main.dart';
import 'package:kakunin/screen/home/home_model.dart';
import 'package:kakunin/utils/log.dart';
import 'package:kakunin/utils/parse.dart';
import 'package:local_auth/local_auth.dart';

class HomeView extends StatefulHookConsumerWidget {
  const HomeView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final needAuth = spInstance.getBool("auth") ?? false;
  final LocalAuthentication auth = LocalAuthentication();
  @override
  Widget build(BuildContext context) {
    super.build(context);
    // final appLifecycleState = useAppLifecycleState();

    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final verificationItems = ref.watch(verificationItemsProvider);
    // final tokenItems = ref.watch(tokenValueProvider);
    // final timeItems = ref.watch(timeLeftProvider);
    // final timeMaps = ref.watch(timeValueProvider);
    Future<bool> authHandler() async {
      Log.e(needAuth, 'needAuth');
      if (!needAuth) {
        return true;
      } else {
        final bool didAuthenticate = await auth.authenticate(localizedReason: '请验证您的身份信息');
        return (didAuthenticate);
      }
    }

    final scrollController = useScrollController(keepScrollOffset: true);
    final authFuture = useFuture(useMemoized(() => authHandler()), initialData: null);
    // final dy = useState(0.0);
    // scrollListener() {
    //   dy.value = scrollController.position.pixels;
    // }

    // final demo = ref.watch(demoValueProvider);
    // final verificationItems = useState<List<VerificationItem>>([]);
    // useEffect(() {
    //   // verificationItems.value = _isar.verificationItems.where().findAllSync();
    //   scrollController.addListener(scrollListener);
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     scrollController.jumpTo(dy.value); // 恢复 ScrollController 的位置
    //   });
    //   return () {
    //     scrollController.removeListener(scrollListener);
    //   };
    // }, []);

    useEffect(() {
      if (authFuture.data != null) {
        if (authFuture.data!) {
          Future(() {
            ref.read(verificationItemsProvider.notifier).refresh();
          });
        } else {
          // SystemNavigator.pop();
          // exit(0);
          FlutterExitApp.exitApp();
        }
      }
      return () {};
    }, [authFuture.data]);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Transform.translate(offset: const Offset(0, -2), child: const Text("身份验证器")),
        elevation: 4,
        actions: [
          IconButton(
              onPressed: () {
                GoRouter.of(context).push("/config");
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      body: ListView.builder(
        controller: scrollController,
        itemCount: verificationItems.length,
        itemBuilder: (context, index) {
          final item = verificationItems[index];

          return item;
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return SafeArea(
                  child: Wrap(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.camera),
                    title: Transform.translate(
                      offset: const Offset(0, -1.2),
                      child: const Text('扫描二维码'),
                    ),
                    onTap: () async {
                      GoRouter.of(context).pop();
                      GoRouter.of(context).push("/scan");
                      // WidgetsBinding.instance.addPostFrameCallback((_) {
                      //   if (res != null) {
                      //     ref.read(verificationItemsProvider.notifier).insertItem(res);
                      //   }
                      // });
                    },
                  ),
                  // ListTile(
                  //   leading: const Icon(Icons.camera_alt),
                  //   title: Transform.translate(offset: const Offset(0, -1.2), child: const Text('扫描本地图片')),
                  //   onTap: () {},
                  // ),
                  ListTile(
                    leading: const Icon(Icons.grid_view_rounded),
                    title: Transform.translate(offset: const Offset(0, -1.2), child: const Text('手动输入')),
                    onTap: () async {
                      GoRouter.of(context).pop();
                      GoRouter.of(context).push("/code");
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.folder),
                    title: Transform.translate(offset: const Offset(0, -1.2), child: const Text('解析 URI')),
                    onTap: () {
                      Navigator.of(context).pop();
                      openUriDialog(context);
                    },
                  ),
                ],
              ));
            },
          );
          // _scaffoldKey.currentState?.showBottomSheet((context) {
          //   return Container(
          //     width: MediaQuery.of(context).size.width,
          //     height: 200,
          //   );
          // });
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void openUriDialog(BuildContext context) {
    final uriController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('从 URI 导入'),
        content: TextField(
          controller: uriController,
          decoration: const InputDecoration(
            isDense: true,
            labelText: 'URI 链接',
            border: OutlineInputBorder(),
          ),
        ),
        actions: <Widget>[
          FilledButton(
            child: const Text('导入'),
            onPressed: () {
              Navigator.of(context).pop();
              var res = Parse.uri(uriController.text);
              if (res.isNotEmpty) {
                ref.read(verificationItemsProvider.notifier).insertItem(res);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                    "您导入的 Uri 链接不包含有效数据",
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                ));
              }
            },
          ),
        ],
      ),
    );
  }
}
