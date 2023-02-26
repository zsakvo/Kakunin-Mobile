// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
// import 'package:go_router_flow/go_router_flow.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:kakunin/data/models/verification_item.dart';
import 'package:kakunin/screen/home/home_model.dart';

import 'components/otp_view.dart';

// enum VerifyType { totp, hotp }

class CodeView extends StatefulHookConsumerWidget {
  const CodeView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CodeViewState();
}

class _CodeViewState extends ConsumerState<CodeView> {
  double top = 0.0;
  final _totpKey = GlobalKey<OtpViewState>();
  final Isar _isar = Isar.getInstance()!;
  @override
  Widget build(BuildContext context) {
    final verifyType = useState(VerifyType.totp);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text("添加新条目"),
            pinned: true,
            leading: Transform.translate(
              offset: const Offset(0, 4),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.pop();
                },
              ),
            ),
            actions: [
              IconButton(
                  onPressed: () {
                    // ref.read(historyBooksListProvider).clear();
                    _totpKey.currentState?.clear();
                  },
                  icon: const Icon(
                    Icons.refresh,
                  ))
            ],
            flexibleSpace: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
              top = constraints.biggest.height;
              return FlexibleSpaceBar(
                title: Text(
                  "添加新条目",
                  style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
                ),
                centerTitle: false,
                titlePadding: EdgeInsetsDirectional.only(
                  start: top > 140 ? 16.0 : 56,
                  bottom: 16.0,
                ),
              );
            }),
          ),
          SliverToBoxAdapter(
            child: Wrap(
              children: [
                // Container(
                //   padding: const EdgeInsets.only(left: 18, top: 12, bottom: 12),
                //   child: const Text(
                //     "添加新条目",
                //     style: TextStyle(fontSize: 20),
                //   ),
                // ),
                Container(
                  margin: const EdgeInsets.only(left: 18, right: 18, top: 18, bottom: 8),
                  // height: 40,
                  width: MediaQuery.of(context).size.width,
                  child: SegmentedButton(
                      // style: const ButtonStyle(
                      //     padding: MaterialStatePropertyAll<EdgeInsets>(EdgeInsets.only(top: 10)),
                      //     minimumSize: MaterialStatePropertyAll<Size>(Size.fromHeight(40)),
                      //     alignment: Alignment.center),
                      onSelectionChanged: (p0) {
                        verifyType.value = p0.first;
                      },
                      segments: const [
                        ButtonSegment(
                            value: VerifyType.totp,
                            label: Text(
                              "TOTP",
                            )),
                        ButtonSegment(
                            value: VerifyType.hotp,
                            label: Text(
                              "HOTP",
                            ))
                      ],
                      selected: <VerifyType>{
                        verifyType.value
                      }),
                ),
                SizedBox(
                  height: 18,
                  width: MediaQuery.of(context).size.width,
                ),
                OtpView(
                  key: _totpKey,
                  verifyType: verifyType.value,
                  onSubmit: (VerificationItem item) {
                    // _isar.writeTxnSync(() {
                    //   _isar.verificationItems.putSync(item);
                    // });
                    ref.read(verificationItemsProvider.notifier).insertItem(item);
                    GoRouter.of(context).pop();
                  },
                )
              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _totpKey.currentState?.submit();
        },
        label: Transform.translate(
          offset: const Offset(0, -1.4),
          child: const Text("保存"),
        ),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
