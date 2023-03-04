// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:kakunin/router.dart';
import 'package:kakunin/screen/home/home_model.dart';
import 'package:kakunin/utils/encode.dart';
import 'package:kakunin/utils/log.dart';
import 'package:kakunin/utils/parse.dart';
import 'package:kakunin/utils/snackbar.dart';

enum CloudAccountType { Google, WebDav, DropBox, AliYun }

class CloudAccount {
  final String? user;
  final String? usage;
  final String? total;
  final bool isLogin;
  final DriveApi? gDriveApi;
  final File? gFile;

  CloudAccount({this.isLogin = false, this.user, this.usage, this.total, this.gDriveApi, this.gFile});

  CloudAccount copyWith(
      {String? user, String? usage, String? total, bool? isLogin, DriveApi? gDriveApi, final File? gFile}) {
    return CloudAccount(
        user: user ?? this.user,
        usage: usage ?? this.usage,
        total: total ?? this.total,
        isLogin: isLogin ?? this.isLogin,
        gDriveApi: gDriveApi ?? this.gDriveApi,
        gFile: gFile ?? this.gFile);
  }
}

class CloudAccountNotifier extends StateNotifier<CloudAccount> {
  CloudAccountNotifier({required this.ref}) : super(CloudAccount(isLogin: false)) {
    // login();
  }
  final dynamic ref;
  late CloudAccountType accountType;
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      // 'https://www.googleapis.com/auth/drive.appdata',
      DriveApi.driveFileScope
      // 'https://www.googleapis.com/auth/drive.appfolder'
    ],
  );
  login(CloudAccountType type, {handle = false}) async {
    try {
      accountType = type;
      switch (type) {
        case CloudAccountType.Google:
          bool isSignedIn = await googleSignIn.isSignedIn();
          if (isSignedIn || (!isSignedIn && handle)) {
            final GoogleSignInAccount? googleAccount =
                handle ? await googleSignIn.signIn() : await googleSignIn.signInSilently();
            Log.e(googleAccount.toString());
            if (googleAccount != null) {
              final client = await googleSignIn.authenticatedClient();
              final driveApi = DriveApi(client!);
              state = CloudAccount(isLogin: true, user: googleAccount.email, gDriveApi: driveApi);
              getQuota();
              searchBackUpFile();
            }
          } else {
            state = CloudAccount(isLogin: false);
          }
          break;
        default:
      }
    } catch (err) {
      Log.e(err.toString(), "catchErr");
      ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!).showSnackBar(SnackBar(
        content: Text(err.toString()),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  getQuota() async {
    final about = await state.gDriveApi!.about.get($fields: "storageQuota");
    final quota = about.storageQuota!;
    state = state.copyWith(
      usage: Parse.formatFileSize(quota.usage!),
      total: Parse.formatFileSize(quota.limit!),
    );
  }

  searchGoogleBakFile() async {
    var res = await state.gDriveApi!.files
        .list(q: "name='kakunin.otp'", $fields: "files(modifiedTime,id,name,createdTime,version,size,md5Checksum)");
    if (res.files!.isEmpty) {
      return null;
    } else {
      var file = res.files!.first;
      Log.e(file.toJson(), "fff");
      state = state.copyWith(gFile: file);
      return file;
    }
  }

  searchBackUpFile() {
    switch (accountType) {
      case CloudAccountType.Google:
        searchGoogleBakFile();
        break;
      default:
    }
  }

  logout() {
    switch (accountType) {
      case CloudAccountType.Google:
        googleSignIn.signOut();
        state = CloudAccount(isLogin: false);
        break;
      default:
    }
  }

  backUp() {
    switch (accountType) {
      case CloudAccountType.Google:
        backUpGoogle();
        break;
      default:
    }
  }

  restore() {
    switch (accountType) {
      case CloudAccountType.Google:
        restoreGoogle();
        break;
      default:
    }
  }

  backUpGoogle() async {
    if (state.isLogin) {
      final File? gFile = state.gFile;
      final String text = await Encode.rsa(ref);
      final ints = text.codeUnits;
      File tmpFile = File(
        name: "kakunin.otp",
        description: "Kakunin 应用备份",
      );
      Media uploadMedia = Media(Stream.value(ints), ints.length);
      if (gFile == null) {
        await state.gDriveApi!.files.create(tmpFile, uploadMedia: uploadMedia);
      } else {
        Log.e(gFile.toJson());
        final id = gFile.id;
        state.gDriveApi!.files.update(tmpFile, id!, uploadMedia: uploadMedia);
      }
      getQuota();
      showSnackBar("备份成功");
    } else {
      final text = Encode.clear(ref);
    }
  }

  restoreGoogle() async {
    final File? gFile = state.gFile;
    if (gFile != null) {
      final file = await state.gDriveApi!.files.get(gFile.id!, downloadOptions: DownloadOptions.fullMedia) as Media;
      final bytes = await file.stream.first;
      String str = utf8.decode(bytes);
      String clearStr = await Encode.decode(str);
      var items = json.decode(clearStr) as List;
      var localItems = ref.read(verificationItemsProvider.notifier).state.map((e) => e.item.uriString).toList() as List;
      int i = 0;
      for (var item in items) {
        if (!localItems.contains(item)) {
          ref.read(verificationItemsProvider.notifier).insertItem(Parse.uri(item));
          i++;
        }
      }
      showSnackBar("完成，共恢复了$i条数据");
    } else {
      showErrorSnackBar("没有找到备份文件");
    }
  }
}

final cloudAccountProvider = StateNotifierProvider<CloudAccountNotifier, CloudAccount>((ref) {
  return CloudAccountNotifier(ref: ref);
});
