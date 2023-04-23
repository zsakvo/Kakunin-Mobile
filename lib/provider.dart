// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'dart:typed_data';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:kakunin/main.dart';
import 'package:kakunin/router.dart';
import 'package:kakunin/screen/home/home_model.dart';
import 'package:kakunin/utils/encode.dart';
import 'package:kakunin/utils/i18n.dart';
import 'package:kakunin/utils/log.dart';
import 'package:kakunin/utils/parse.dart';
import 'package:kakunin/utils/snackbar.dart';
import 'package:webdav_client/webdav_client.dart' as wd;

enum CloudAccountType { Google, WebDav, DropBox, AliYun }

const String defaultFileName = 'kakunin.otp';

class CloudAccount {
  final String? user;
  final String? usage;
  final String? total;
  final bool isLogin;
  final DriveApi? gDriveApi;
  final File? gFile;
  final String? localDir;
  final String? davPath;
  final String? davUrl;
  final String? davFileSize;
  final String? davFileTime;

  CloudAccount(
      {this.isLogin = false,
      this.user,
      this.usage,
      this.total,
      this.gDriveApi,
      this.gFile,
      this.localDir,
      this.davPath,
      this.davUrl,
      this.davFileSize,
      this.davFileTime});

  CloudAccount copyWith(
      {String? user,
      String? usage,
      String? total,
      bool? isLogin,
      DriveApi? gDriveApi,
      final File? gFile,
      String? localDir,
      String? davPath,
      String? davUrl,
      String? davFileSize,
      String? davFileTime}) {
    return CloudAccount(
        user: user ?? this.user,
        usage: usage ?? this.usage,
        total: total ?? this.total,
        isLogin: isLogin ?? this.isLogin,
        gDriveApi: gDriveApi ?? this.gDriveApi,
        gFile: gFile ?? this.gFile,
        localDir: localDir ?? this.localDir,
        davPath: davPath ?? this.davPath,
        davUrl: davUrl ?? this.davUrl,
        davFileSize: davFileSize ?? this.davFileSize,
        davFileTime: davFileTime ?? this.davFileTime);
  }

  Map<String, dynamic> toMap() {
    return {
      'user': user,
      'usage': usage,
      'total': total,
      'isLogin': isLogin,
      'gDriveApi': gDriveApi?.toString(),
      'gFile': gFile?.toString(),
      'localDir': localDir,
      'davFileSize': davFileSize,
      'davFileTime': davFileTime,
    };
  }

  factory CloudAccount.fromMap(Map<String, dynamic> map) {
    return CloudAccount(
      user: map['user'],
      usage: map['usage'],
      total: map['total'],
      isLogin: map['isLogin'] ?? false,
      gDriveApi: null,
      gFile: null,
      localDir: map['localDir'],
      davFileSize: map['davFileSize'],
      davFileTime: map['davFileTime'],
    );
  }

  String toJson() => json.encode(toMap());

  factory CloudAccount.fromJson(String source) => CloudAccount.fromMap(json.decode(source));
}

class CloudAccountNotifier extends StateNotifier<CloudAccount> {
  CloudAccountNotifier({required this.ref})
      : super(CloudAccount(isLogin: false, localDir: spInstance.getString("localDir")));
  final dynamic ref;
  late CloudAccountType accountType;
  late wd.Client davClient;
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
            if (googleAccount != null) {
              final client = await googleSignIn.authenticatedClient();
              final driveApi = DriveApi(client!);
              state = state.copyWith(isLogin: true, user: googleAccount.email, gDriveApi: driveApi);
              getQuota();
              searchBackUpFile();
            }
          } else {
            state = state.copyWith(isLogin: false);
          }
          break;
        case CloudAccountType.WebDav:
          GoRouter.of(NavigationService.navigatorKey.currentContext!).push("/webdav");
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

  checkLogin(CloudAccountType type) async {
    state = state.copyWith(isLogin: false);
    if (type == CloudAccountType.Google) {
      login(type);
    } else {
      checkDavToken();
    }
  }

  checkDavToken() async {
    accountType = CloudAccountType.WebDav;
    final url = spInstance.getString("davUrl")!;
    final account = spInstance.getString("davAccount")!;
    final password = spInstance.getString("davPassword")!;
    final davPath = spInstance.getString("davPath") ?? "/";
    davClient = wd.newClient(
      url,
      user: account,
      password: password,
      debug: true,
    )..setHeaders({'accept-charset': 'utf-8'});
    try {
      await davClient.readDir(davPath);
      state = state.copyWith(isLogin: true, davPath: davPath, davUrl: url);
      searchBackUpFile();
    } catch (err) {
      Log.e(err);
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
      state = state.copyWith(gFile: file);
      return file;
    }
  }

  searchWebDavFile() async {
    var res = await davClient.readProps(state.davPath! + defaultFileName);
    if (res.size != null && res.mTime != null) {
      state = state.copyWith(
          davFileTime: res.mTime!.toLocal().toString(), davFileSize: Parse.formatFileSize(res.size!.toString()));
    }
  }

  searchBackUpFile() {
    switch (accountType) {
      case CloudAccountType.Google:
        searchGoogleBakFile();
        break;
      case CloudAccountType.WebDav:
        searchWebDavFile();
        break;
      default:
    }
  }

  logout() {
    switch (accountType) {
      case CloudAccountType.Google:
        googleSignIn.signOut();
        state = state.copyWith(isLogin: false);
        break;
      default:
    }
  }

  backUpWebDav() async {
    try {
      final String text = await Encode.rsa(ref);
      await davClient.write(
        "${state.davPath!}kakunin.otp",
        utf8.encode(text) as Uint8List,
      );
      showSnackBar("备份成功");
    } catch (err) {
      showErrorSnackBar(err.toString());
    }
  }

  backUp() {
    switch (accountType) {
      case CloudAccountType.Google:
        backUpGoogle();
        break;
      case CloudAccountType.WebDav:
        backUpWebDav();
        break;
      default:
    }
  }

  restore() {
    switch (accountType) {
      case CloudAccountType.Google:
        restoreGoogle();
        break;
      case CloudAccountType.WebDav:
        restoreWebDav();
        break;
      default:
    }
  }

  backUpGoogle() async {
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
    searchBackUpFile();
    showSnackBar("备份成功");
  }

  backUpLocal() async {
    final text = Encode.clear(ref);
    String? selectedDirectory = state.localDir ?? await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      spInstance.setString("localDir", selectedDirectory);
      state = state.copyWith(localDir: selectedDirectory);
      io.File file = io.File("$selectedDirectory/kakunin.otp");
      file.createSync();
      file.writeAsStringSync(text);
      showSnackBar("备份成功");
    } else {
      showErrorSnackBar("请先选好备份位置");
    }
  }

  resetLocalDir() async {
    var res = await FilePicker.platform.getDirectoryPath();
    state = state.copyWith(localDir: res);
  }

  restoreGoogle() async {
    final File? gFile = state.gFile;
    if (gFile != null) {
      final file = await state.gDriveApi!.files.get(gFile.id!, downloadOptions: DownloadOptions.fullMedia) as Media;
      final bytes = await streamToList(file.stream);
      String str = utf8.decode(bytes);
      String clearStr = await Encode.decode(str);
      restoreClearString(clearStr);
    } else {
      showErrorSnackBar("没有找到备份文件");
    }
  }

  restoreWebDav() async {
    try {
      var res = await davClient.read(
        Uri.encodeComponent(state.davPath! + defaultFileName),
      );
      String str = utf8.decode(res);
      String clearStr = await Encode.decode(str);
      restoreClearString(clearStr);
    } catch (err) {
      Log.e(err);
      showErrorSnackBar(err.toString());
    }
  }

  restoreLocal() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(dialogTitle: "选择您的备份文件", type: FileType.custom, allowedExtensions: ["otp"]);
    if (result != null) {
      io.File file = io.File(result.files.single.path!);
      String clearStr = file.readAsStringSync();
      restoreClearString(clearStr);
    } else {
      // User canceled the picker
      showErrorSnackBar("未选择任何文件");
    }
  }

  restoreClearString(String clearStr) {
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
  }

  storeWebDavAccount({required String url, required String account, required String password}) {
    state = state.copyWith(isLogin: true);
    spInstance.setString("davUrl", url);
    spInstance.setString("davAccount", account);
    spInstance.setString("davPassword", password);
  }

  setWebDavPath(context) {
    final davUrl = spInstance.getString("davUrl");
    if (davUrl != null) {
      GoRouter.of(context).push("/webdavPath");
    } else {
      showErrorSnackBar("Please log in to WebDAV first".i18n);
    }
  }
}

final cloudAccountProvider = StateNotifierProvider<CloudAccountNotifier, CloudAccount>((ref) {
  return CloudAccountNotifier(ref: ref);
});

Future<List<int>> streamToList(Stream<List<int>> stream) async {
  final completer = Completer<List<int>>();
  final sink = ByteConversionSink.withCallback((bytes) => completer.complete(bytes));

  await stream.listen(sink.add).asFuture();
  sink.close();

  return completer.future;
}
