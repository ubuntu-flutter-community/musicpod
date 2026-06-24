class LastFmCredentials {
  LastFmCredentials({required this.apiKey, required this.apiSecret});

  final String apiKey;
  final String apiSecret;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LastFmCredentials &&
          runtimeType == other.runtimeType &&
          apiKey == other.apiKey &&
          apiSecret == other.apiSecret;

  @override
  int get hashCode => apiKey.hashCode ^ apiSecret.hashCode;
}
