class ApiConfig {
  static const defaultBaseUrl = 'http://mas.phyliatech.com/';
  static const defaultConnectTimeout = Duration(seconds: 30);
  static const defaultReceiveTimeout = Duration(seconds: 30);

  static const defaultHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
}
