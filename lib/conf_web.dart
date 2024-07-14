import 'dart:html' show document;
import 'package:flutter/material.dart';

void webConfigure() {
  debugPrint('configure web');
  debugPrint('attributes: ${document.head?.attributes}');
  debugPrint('dataset: ${queryMeta("description", "content")}');
}

String queryMeta(String name, String content) {
  return document.documentElement
          ?.querySelector('meta[name="$name"]')
          ?.getAttribute(content) ??
      "";
}
