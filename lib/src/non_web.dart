final window = Window();

class Window {
  Location get location => Location();
  History get history => History();
}

class History {
  void replaceState(dynamic data, String title, String url) {}
  String? state;
}

class Location {
  String? href;
}
