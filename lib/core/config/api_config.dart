class ApiConfig {
  static const String host = String.fromEnvironment(
    'API_HOST',
    defaultValue: 'http://192.168.11.215:8000',
  );

  static const String apiBaseUrl = '$host/api';
}