import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:url_launcher/url_launcher.dart';

/// dependency
///   http: ^1.2.1
///   markdown_widget: ^2.3.2+6
/// Markdown_Widget的图片处理
/// 图片地址不是http开头的，转由flutter的系统Widget处理：Image.asset

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static final String suffix = "${Uri.base.origin}/page";

  var pageUrl = Uri.parse("$suffix/index.md");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              width: 720,
              margin: const EdgeInsets.all(8),
              decoration: createBoxDecoration(),
              child: buildFuture(),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration createBoxDecoration() {
    return BoxDecoration(
      border: Border.all(
        color: Colors.grey.withOpacity(0.2),
        width: 1,
      ),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          blurRadius: 10,
          spreadRadius: 0.1,
          color: Colors.grey.withOpacity(0.2),
        ),
      ],
      borderRadius: BorderRadius.circular(10),
    );
  }

  Widget buildFuture() {
    final config = MarkdownConfig(configs: [
      LinkConfig(onTap: (url) {
        var isNetUrl = url.startsWith('http://') || url.startsWith('https://');
        if (!isNetUrl) {
          setState(() {
            pageUrl = Uri.parse("$suffix/$url");
          });
        } else {
          launchUrl(Uri.parse(url));
        }
      }),
      ImgConfig(builder: (String imgUrl, Map<String, String> attributes) {
        final isNetImage =
            imgUrl.startsWith('http://') || imgUrl.startsWith('https://');
        final img = isNetImage ? imgUrl : "$suffix/$imgUrl";
        return Image.network(img, fit: BoxFit.cover, errorBuilder: (c, e, _) {
          return const Icon(Icons.broken_image, color: Colors.grey);
        });
      })
    ]);
    return FutureBuilder<String>(
      future: mockNetworkData(pageUrl),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          }
          return Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
            child: MarkdownBlock(
              data: snapshot.data,
              config: config,
            ),
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Future<String> mockNetworkData(Uri url) async {
    try {
      final headers = <String, String>{'charset': 'utf-8'};
      final response = await http.get(url, headers: headers);
      debugPrint('Response status: ${response.statusCode}');

      // 方法1：手动解析
      // final content = utf8.decode(response.bodyBytes);
      // debugPrint('Response body: $content');

      // 方法2：在content-type设置charset
      // 直接设置charset是无效的，如 response.headers['charset'] = 'utf-8';
      response.headers['content-type'] = 'text/plain; charset=utf-8';
      return Future(() => response.body);
    } catch (exception) {
      return Future(() => "404");
    }
  }
}
