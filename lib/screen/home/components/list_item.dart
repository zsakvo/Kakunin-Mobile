import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakunin/data/models/verification_item.dart';
import 'package:kakunin/screen/home/home_model.dart';
import 'package:otp/otp.dart';
import 'package:timezone/timezone.dart' as timezone;

final pacificTimeZone = timezone.getLocation('Asia/Shanghai');

class ListItemView extends StatefulHookConsumerWidget {
  const ListItemView({super.key, required this.item});

  final VerificationItem item;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => ListItemViewState();
}

class ListItemViewState extends ConsumerState<ListItemView>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  double preValue = 1.0;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final token = useState("");
    final algorithm = useState<Algorithm>(getSha(widget.item.sha!));
    final used = useState(widget.item.used ?? 0);
    final animationController = useAnimationController(
      initialValue: 0,
      lowerBound: 0,
      upperBound: 1,
      vsync: this,
      duration: Duration(seconds: widget.item.time!),
    )..repeat();
    useEffect(() {
      final value = animationController.value;
      if (value <= preValue && widget.item.type == "TOTP") {
        final now = DateTime.now();
        final date = timezone.TZDateTime.from(now, pacificTimeZone);
        token.value = (OTP
                .generateTOTPCodeString(widget.item.key!, date.millisecondsSinceEpoch,
                    algorithm: algorithm.value, isGoogle: true)
                .split("")
              ..insert(3, " "))
            .join("");
      }
      preValue = value;
      return () {};
    }, [animationController.value]);

    getHotp() {
      token.value = (OTP
              .generateHOTPCodeString(algorithm: algorithm.value, widget.item.key!, used.value, isGoogle: true)
              .split("")
            ..insert(3, " "))
          .join("");
    }

    useEffect(() {
      if (widget.item.type == "TOTP") {
        animationController.forward();
      } else {
        getHotp();
      }
      return () {
        animationController.dispose();
      };
    }, []);
    useAnimation(animationController);

    return Material(
        child: InkWell(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 18,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.name!,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                Text(
                  token.value,
                  style: TextStyle(
                      fontSize: 24, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
                )
              ],
            ),
            widget.item.type == "TOTP"
                ? SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(
                      value: animationController.value,
                      //  Parse.timeValue(timeMaps[item.id], item.time!),
                      strokeWidth: 10,
                      semanticsLabel: 'Circular progress indicator',
                    ),
                  )
                : GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Transform.translate(
                      offset: const Offset(14.0, 0),
                      child: Container(
                          color: Colors.transparent,
                          padding: const EdgeInsets.all(14),
                          child: const Icon(Icons.refresh)),
                    ),
                    onTap: () {
                      used.value++;
                      getHotp();
                      ref.read(verificationItemsProvider.notifier).updateHotp(widget.item.id, used.value);
                    },
                  ),
          ],
        ),
      ),
      onTap: () {
        FlutterClipboard.copy(token.value).then((value) => ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(behavior: SnackBarBehavior.floating, content: Text("验证码复制成功"))));
      },
      onLongPress: () {
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
                  leading: const Icon(Icons.edit),
                  title: Transform.translate(
                    offset: const Offset(0, -1.2),
                    child: const Text('编辑信息'),
                  ),
                  onTap: () async {
                    GoRouter.of(context).pop();
                    GoRouter.of(context).push("/scan");
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: Transform.translate(offset: const Offset(0, -1.2), child: const Text('删除条目')),
                  onTap: () {
                    GoRouter.of(context).pop();
                    ref.read(verificationItemsProvider.notifier).deleteItem(widget.item);
                  },
                ),
              ],
            ));
          },
        );
      },
    ));
  }

  getSha(String str) {
    switch (str) {
      case "SHA1":
        return Algorithm.SHA1;
      case "SHA256":
        return Algorithm.SHA256;
      case "SHA512":
        return Algorithm.SHA512;
    }
  }
}
