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

class ListItemViewState extends ConsumerState<ListItemView> {
  double preValue = 1.0;

  @override
  Widget build(BuildContext context) {
    useAutomaticKeepAlive(wantKeepAlive: true);
    final vsync = useSingleTickerProvider();
    final token = useState("");
    final algorithm = useState<Algorithm>(getSha(widget.item.sha!));
    final counter = useState(widget.item.counter ?? 0);
    final extraStr = (widget.item.vendor != null && widget.item.vendor!.isNotEmpty) ? " (${widget.item.vendor})" : "";
    late final animationController = useAnimationController(
      initialValue: 0,
      lowerBound: 0,
      upperBound: 1,
      vsync: vsync,
      duration: Duration(seconds: widget.item.time!),
    );

    useEffect(() {
      final value = animationController.value;
      if (value <= preValue && widget.item.type == "TOTP") {
        final now = DateTime.now();
        final date = timezone.TZDateTime.from(now, pacificTimeZone);
        try {
          token.value = (OTP
                  .generateTOTPCodeString(widget.item.key!, date.millisecondsSinceEpoch,
                      algorithm: algorithm.value, isGoogle: true)
                  .split("")
                ..insert(3, " "))
              .join("");
        } catch (err) {
          token.value = err.toString();
        }
      }
      preValue = value;
      return () {};
    }, [animationController.value]);

    getHotp() {
      try {
        token.value = (OTP
                .generateHOTPCodeString(algorithm: algorithm.value, widget.item.key!, counter.value, isGoogle: true)
                .split("")
              ..insert(3, " "))
            .join("");
      } catch (err) {
        token.value = "error";
      }
    }

    useEffect(() {
      if (widget.item.type == "TOTP") {
        final leftTime = OTP.remainingSeconds(interval: widget.item.time!) * 1.0;
        animationController.value = (widget.item.time! - leftTime) / widget.item.time!;
        animationController.repeat();
      } else {
        getHotp();
      }
      return () {};
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.name! + extraStr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    token.value,
                    style: TextStyle(
                        fontSize: 24, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500),
                  )
                ],
              ),
            ),
            widget.item.type == "TOTP"
                ? Container(
                    margin: const EdgeInsets.only(right: 6),
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
                      counter.value++;
                      getHotp();
                      ref.read(verificationItemsProvider.notifier).updateHotp(widget.item.id, counter.value);
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
                    GoRouter.of(context).push("/code", extra: widget.item.copyWith(counter: counter.value));
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
