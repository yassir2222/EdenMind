class AppConfig {
  // Global IP address for the backend server
  // Change this to your computer's IP address (e.g., from ipconfig)
  static const String serverIp = 'localhost';
  static const String serverPort = '8081';

  static String get baseUrl => 'http://$serverIp:$serverPort/api';
}
