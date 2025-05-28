// Mock implementation of dart:html for non-web platforms

class Window {
  final Storage localStorage = Storage();
}

class Storage {
  final Map<String, String> _data = {};
  
  String? operator [](String key) => _data[key];
  
  void operator []=(String key, String value) {
    _data[key] = value;
  }
  
  void remove(String key) {
    _data.remove(key);
  }
}

final Window window = Window();
