// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

String? localStorageGet(String key) => html.window.localStorage[key];
void localStorageSet(String key, String value) => html.window.localStorage[key] = value;
void localStorageRemove(String key) => html.window.localStorage.remove(key);
