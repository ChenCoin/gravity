import 'package:gravity/conf_web.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:url_launcher/url_launcher.dart';

/// dependency
///   http: ^1.2.1
///   markdown_widget: ^2.3.2+6
/// Markdown_Widget的图片处理
/// 图片地址不是http开头的，转由flutter的系统Widget处理：Image.asset

String suffix = "";

void main() {
  String rootPath = queryMeta("markdown-root", "content");
  if (!rootPath.startsWith('/')) {
    rootPath = "/$rootPath";
  }
  suffix = "${Uri.base.origin}$rootPath";
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
      home: const HomePage(),
      onUnknownRoute: (routeSettings) => MaterialPageRoute(
        settings: routeSettings,
        builder: (_) => const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var routePath = ModalRoute.of(context)?.settings.name ?? "/";
    debugPrint("routePath: $routePath");
    var pageUrl = routePath == "/" ? "$suffix/index.md" : "$suffix$routePath";
    return Scaffold(
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              width: 720,
              margin: const EdgeInsets.all(8),
              decoration: createBoxDecoration(),
              child: buildFuture(pageUrl, routePath),
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

  Widget buildFuture(String pageUrl, String routePath) {
    debugPrint("pageUrl: $pageUrl, routePath: $routePath");
    final parentPath = pageUrl.substring(0, pageUrl.lastIndexOf('/'));
    final parentRoute = routePath.substring(0, routePath.lastIndexOf('/'));
    debugPrint("parentPath: $parentPath, parentRoute: $parentRoute");
    final config = MarkdownConfig(
        configs: [urlConfig(parentPath, parentRoute), imgConfig(parentPath)]);
    return FutureBuilder<String>(
      future: mockNetworkData(Uri.parse(pageUrl)),
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
      return Future(() => "# 404");
    }
  }

  WidgetConfig urlConfig(String parentPath, String parentRoute) {
    return LinkConfig(onTap: (url) {
      // open new tab when it is normal url
      if (url.startsWith('http://') || url.startsWith('https://')) {
        launchUrl(Uri.parse(url));
        return;
      }
      // reload markdown file when url is another markdown on server
      if (url.endsWith('.md') || url.endsWith('.markdown')) {
        debugPrint("url clicked: $url");
        if (url.startsWith('/')) {
          Navigator.pushNamed(context, url);
          return;
        }
        Navigator.pushNamed(context, "$parentRoute/$url");
        return;
      }
      // open new tab when it is local server url
      launchUrl(Uri.parse("$parentPath/$url"));
    });
  }

  WidgetConfig imgConfig(String parentPath) {
    return ImgConfig(builder: (String imgUrl, Map<String, String> attributes) {
      debugPrint("photo: $imgUrl $attributes");
      final isNetImage =
          imgUrl.startsWith('http://') || imgUrl.startsWith('https://');
      final img = isNetImage ? imgUrl : "$parentPath/$imgUrl";
      return Center(
        child: Image.network(img, fit: BoxFit.cover, errorBuilder: (c, e, _) {
          return const Icon(Icons.broken_image, color: Colors.grey);
        }),
      );
    });
  }
}
