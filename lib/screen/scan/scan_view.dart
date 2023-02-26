import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
// import 'package:go_router_flow/go_router_flow.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakunin/screen/home/home_model.dart';
import 'package:kakunin/utils/log.dart';
import 'package:kakunin/utils/parse.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';

class ScanView extends StatefulHookConsumerWidget {
  const ScanView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ScanViewState();
}

class _ScanViewState extends ConsumerState<ScanView> {
  final MobileScannerController controller = MobileScannerController(
    torchEnabled: false,
    formats: [BarcodeFormat.qrCode],
  );
  // 有bug所以手动搞一下
  bool scanned = false;
  @override
  Widget build(BuildContext context) {
    final isFlashOn = useState(false);
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (barcodes) {
              if (scanned) {
                return;
              } else {
                scanned = true;
                final rawString = barcodes.barcodes.first.rawValue;
                Log.e(rawString, "barcode");
                var res = Parse.uri(rawString ?? "");
                if (res == null) {
                  openWarnDialog(context);
                } else {
                  // ref.read(verificationItemsProvider.notifier).insertItem(res);
                  GoRouter.of(context).pop(res);
                }
              }
            },
          ),
          Positioned(
              right: 16,
              bottom: 16,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FloatingActionButton.small(
                      heroTag: null,
                      backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                      foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
                      onPressed: () {
                        controller.toggleTorch();
                        isFlashOn.value = !isFlashOn.value;
                      },
                      child: Icon(isFlashOn.value ? Icons.flash_off : Icons.flash_on),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    FloatingActionButton.extended(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (image != null) {
                          if (await controller.analyzeImage(image.path)) {
                            if (!mounted) return;
                          } else {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No barcode found!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      label: const Text("选取图像"),
                      icon: const Icon(Icons.image),
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }

  void openWarnDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('出现错误'),
        content: const Text('无法识别到当前图片中的有效二维码，请换一张重新尝试'),
        actions: <Widget>[
          FilledButton(
            child: const Text('好的'),
            onPressed: () {
              Navigator.of(context).pop();
              scanned = false;
            },
          ),
        ],
      ),
    );
  }
}
