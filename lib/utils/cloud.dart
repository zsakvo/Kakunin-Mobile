import 'package:kakunin/provider.dart';

class CloudUtil {
  static getHint(CloudAccountType type) {
    switch (type) {
      case CloudAccountType.Google:
        return "程序会在 Google 云端硬盘上新建名为 kakunin.otp 的文件作为备份数据。请保证您的云端（包括回收站在内）只有一个该名字的文件存在。";
      default:
    }
  }
}
