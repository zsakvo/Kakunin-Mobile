import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

class LibDetailView extends HookConsumerWidget {
  const LibDetailView({super.key, required this.lib});
  final String lib;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<String> getLicenseString() async {
      RegExp regex = RegExp(r'<pre.*?>([\s\S]*?)<\/pre>', multiLine: true, dotAll: true);

      // return await rootBundle.loadString("assets/licenses/$lib");
      final response = await http.get(Uri.parse('https://pub.dev/packages/$lib/license'));
      if (response.statusCode == 200) {
        // 获取网页源代码
        String source = response.body;
        Iterable<Match> matches = regex.allMatches(source);
        if (matches.isNotEmpty) {
          // 提取匹配的文本
          var unescape = HtmlUnescape();
          return unescape.convert(matches.map((match) => match.group(1)).join(''));
        } else {
          return 'License fetch failed.';
        }
      } else {
        // 处理错误
        // throw Exception('Failed to fetch web page');
        return 'License fetch failed.';
      }
    }

    final licenseString = useFuture(useMemoized(() => getLicenseString()), initialData: "");
    return Scaffold(
      appBar: AppBar(
        title: Text(
          lib,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        elevation: 4,
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          child: Text(
            licenseString.data!,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      )),
    );
  }
}
