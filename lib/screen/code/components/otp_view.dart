import 'package:flutter/material.dart' hide DropdownMenu, DropdownMenuEntry;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakunin/components/dropdown_menu.dart';
import 'package:kakunin/data/models/verification_item.dart';

enum VerifyType { totp, hotp }

class OtpView extends StatefulHookConsumerWidget {
  const OtpView({super.key, required this.onSubmit, this.verifyType = VerifyType.totp});

  final Function(VerificationItem item) onSubmit;
  final VerifyType verifyType;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => OtpViewState();
}

class OtpViewState extends ConsumerState<OtpView> {
  final nameController = TextEditingController();
  final vendorController = TextEditingController();
  final keyController = TextEditingController();
  final timeController = TextEditingController(text: "30");
  final lengthController = TextEditingController(text: "6");
  final counterController = TextEditingController(text: "0");
  final shaController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: TextField(
              controller: nameController,
              decoration: const InputDecoration(
                isDense: true,
                labelText: '名称',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: TextField(
              controller: vendorController,
              decoration: const InputDecoration(
                isDense: true,
                labelText: '服务商',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: TextField(
              controller: keyController,
              decoration: const InputDecoration(
                isDense: true,
                labelText: '密钥',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(children: [
              Flexible(
                child: widget.verifyType == VerifyType.totp
                    ? TextField(
                        controller: timeController,
                        decoration: const InputDecoration(
                          isDense: true,
                          labelText: '时间间隔',
                          border: OutlineInputBorder(),
                        ),
                      )
                    : TextField(
                        controller: counterController,
                        decoration: const InputDecoration(
                          isDense: true,
                          labelText: '计数器',
                          border: OutlineInputBorder(),
                        ),
                      ),
              ),
              const SizedBox(
                width: 16,
              ),
              Flexible(
                child: TextField(
                  controller: lengthController,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: '位数',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(children: [
              Flexible(
                child: DropdownMenu<String>(
                  controller: shaController,
                  initialSelection: "SHA1",
                  enableSearch: false,
                  enableFilter: false,
                  label: const Text('哈希函数'),
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(
                      label: "SHA1",
                      value: "SHA1",
                    ),
                    DropdownMenuEntry(label: "SHA128", value: "SHA128"),
                    DropdownMenuEntry(label: "SHA256", value: "SHA256")
                  ],
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              const Spacer()
            ]),
          ),
        ],
      ),
    );
  }

  submit() {
    final VerificationItem item = VerificationItem(
        type: widget.verifyType == VerifyType.totp ? "TOTP" : "HOTP",
        name: nameController.text,
        vendor: vendorController.text,
        key: keyController.text,
        time: int.tryParse(timeController.text),
        length: int.tryParse(lengthController.text),
        counter: int.tryParse(counterController.text),
        used: 0,
        sha: shaController.text);
    widget.onSubmit(item);
  }

  clear() {
    nameController.clear();
    vendorController.clear();
    keyController.clear();
    timeController.text = "30";
    lengthController.text = "6";
    counterController.text = "0";
    shaController.text = "SHA1";
  }
}
