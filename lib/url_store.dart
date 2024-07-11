class UrlStore {
  static final UrlStore _instance = UrlStore._internal();
  factory UrlStore() => _instance;
  UrlStore._internal();

  final _value = <String, String?>{};

  String? put({required String key, String? url}) {
    return _value.containsKey(key)
        ? _value.update(key, (value) => url)
        : _value.putIfAbsent(key, () => url);
  }

  String? get(String? icyTitle) => icyTitle == null ? null : _value[icyTitle];
}
