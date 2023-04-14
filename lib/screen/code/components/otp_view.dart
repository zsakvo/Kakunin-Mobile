import 'package:flutter/material.dart' hide DropdownMenu, DropdownMenuEntry;
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakunin/components/dropdown_menu.dart';
import 'package:kakunin/data/models/verification_item.dart';
import 'package:base32/base32.dart';
import 'package:kakunin/utils/i18n.dart';

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
  String? nameErrorText;
  String? keyErrorText;
  int? id;
  // String? nameErrorText;
  // String? nameErrorText;
  bool valid = true;
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
              decoration: InputDecoration(
                  isDense: true, labelText: 'Name'.i18n, border: const OutlineInputBorder(), errorText: nameErrorText),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: TextField(
              controller: vendorController,
              decoration: InputDecoration(
                isDense: true,
                labelText: "Service Provider".i18n,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: TextField(
              controller: keyController,
              decoration: InputDecoration(
                  isDense: true,
                  labelText: "Access Key".i18n,
                  border: const OutlineInputBorder(),
                  errorText: keyErrorText),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(children: [
              Flexible(
                child: widget.verifyType == VerifyType.totp
                    ? TextField(
                        controller: timeController,
                        decoration: InputDecoration(
                          isDense: true,
                          labelText: 'Time Interval'.i18n,
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      )
                    : TextField(
                        controller: counterController,
                        decoration: InputDecoration(
                          isDense: true,
                          labelText: 'Counter'.i18n,
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
              ),
              const SizedBox(
                width: 16,
              ),
              Flexible(
                child: TextField(
                  controller: lengthController,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: 'Digits'.i18n,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                  label: Text('Hash Function'.i18n),
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

  verify() {
    if (nameController.text.trim().isEmpty) {
      nameErrorText = "Name cannot be empty".i18n;
      valid = false;
    } else {
      nameErrorText = null;
      valid = true;
    }

    if (keyController.text.isEmpty) {
      keyErrorText = "Access Key cannot be empty".i18n;
    } else {
      try {
        base32.decodeAsHexString(keyController.text);
        valid = true;
      } catch (err) {
        keyErrorText = "Access Key is not a valid Base32 encoding".i18n;
        valid = false;
      }
    }
    setState(() {});
  }

  submit() {
    final VerificationItem item = VerificationItem(
        id: id,
        type: widget.verifyType == VerifyType.totp ? "TOTP" : "HOTP",
        name: nameController.text,
        vendor: vendorController.text,
        key: keyController.text,
        time: int.tryParse(timeController.text),
        length: int.tryParse(lengthController.text),
        counter: int.tryParse(counterController.text),
        used: 0,
        sha: shaController.text);
    verify();
    if (valid) widget.onSubmit(item);
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

  setContent(VerificationItem item) {
    id = item.id;
    nameController.text = item.name ?? "";
    vendorController.text = item.vendor ?? "";
    keyController.text = item.key ?? "";
    timeController.text = item.time != null ? item.time.toString() : "30";
    lengthController.text = item.length != null ? item.length.toString() : "6";
    counterController.text = item.counter != null ? item.counter.toString() : "0";
    shaController.text = item.sha ?? "SHA1";
  }
}

checkName(String str) {
  return str.isEmpty ? "Name cannot be empty".i18n : null;
}
