abstract final class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.239.129.109:8080',
  );

  static Uri uri(String path) {
    final cleanBaseUrl = baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    final cleanPath = path.startsWith('/') ? path : '/$path';

    return Uri.parse('$cleanBaseUrl$cleanPath');
  }
}
