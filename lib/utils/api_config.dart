class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  
  // Helper to get full URL
  static String getUrl(String path) => '$baseUrl$path';
}
