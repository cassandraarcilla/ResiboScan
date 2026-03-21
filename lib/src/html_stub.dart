// Stub for non-web platforms
class FileUploadInputElement {
  String accept = '';
  bool multiple = false;
  List? files;
  Stream get onChange => const Stream.empty();
  void click() {}
}

class StubFile {
  String get name => '';
  int get size => 0;
}

class FileReader {
  dynamic result;
  Stream get onLoad => const Stream.empty();
  void readAsArrayBuffer(dynamic file) {}
  void readAsDataUrl(dynamic file) {}
}
