import 'dart:html' show document;

String queryMetaFromDocument(String name, String content) {
  String meta = 'meta[name="$name"]';
  return document.querySelector(meta)?.getAttribute(content) ?? "";
}

String queryHtmlMeta(String name) {
  String root = queryMetaFromDocument(name, "content");
  if (!root.startsWith('/')) {
    root = "/$root";
  }
  return root;
}

String queryHtmlTitle() {
  return document.title;
}
