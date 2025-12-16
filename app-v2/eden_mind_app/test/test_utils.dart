import 'dart:async';
import 'dart:convert';
import 'dart:io';

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _createMockImageHttpClient(context);
  }
}

// Returns a mock client that responds with a transparent 1x1 pixel image
HttpClient _createMockImageHttpClient(SecurityContext? _) {
  return _MockHttpClient();
}

class _MockHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Duration? connectionTimeout;

  @override
  Duration idleTimeout = const Duration(seconds: 15);

  @override
  int? maxConnectionsPerHost;

  @override
  String? userAgent;

  @override
  void addCredentials(
    Uri url,
    String realm,
    HttpClientCredentials credentials,
  ) {}

  @override
  void addProxyCredentials(
    String host,
    int port,
    String realm,
    HttpClientCredentials credentials,
  ) {}

  @override
  set authenticate(
    Future<bool> Function(Uri url, String scheme, String? realm)? f,
  ) {}

  @override
  set authenticateProxy(
    Future<bool> Function(String host, int port, String scheme, String? realm)?
    f,
  ) {}

  @override
  set badCertificateCallback(
    bool Function(X509Certificate cert, String host, int port)? callback,
  ) {}

  @override
  void close({bool force = false}) {}

  @override
  set connectionFactory(
    Future<ConnectionTask<Socket>> Function(
      Uri url,
      String? proxyHost,
      int? proxyPort,
    )?
    f,
  ) {}

  @override
  set findProxy(String Function(Uri url)? f) {}

  @override
  set keyLog(void Function(String line)? callback) {}

  @override
  Future<HttpClientRequest> open(
    String method,
    String host,
    int port,
    String path,
  ) async {
    return _MockHttpClientRequest();
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return _MockHttpClientRequest();
  }

  @override
  Future<HttpClientRequest> patch(String host, int port, String path) async {
    return _MockHttpClientRequest();
  }

  @override
  Future<HttpClientRequest> patchUrl(Uri url) async {
    return _MockHttpClientRequest();
  }

  @override
  Future<HttpClientRequest> post(String host, int port, String path) async {
    return _MockHttpClientRequest();
  }

  @override
  Future<HttpClientRequest> postUrl(Uri url) async {
    return _MockHttpClientRequest();
  }

  @override
  Future<HttpClientRequest> put(String host, int port, String path) async {
    return _MockHttpClientRequest();
  }

  @override
  Future<HttpClientRequest> putUrl(Uri url) async {
    return _MockHttpClientRequest();
  }

  @override
  Future<HttpClientRequest> delete(String host, int port, String path) async {
    return _MockHttpClientRequest();
  }

  @override
  Future<HttpClientRequest> deleteUrl(Uri url) async {
    return _MockHttpClientRequest();
  }

  @override
  Future<HttpClientRequest> get(String host, int port, String path) async {
    return _MockHttpClientRequest();
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return _MockHttpClientRequest();
  }

  @override
  Future<HttpClientRequest> head(String host, int port, String path) async {
    return _MockHttpClientRequest();
  }

  @override
  Future<HttpClientRequest> headUrl(Uri url) async {
    return _MockHttpClientRequest();
  }
}

class _MockHttpClientRequest implements HttpClientRequest {
  @override
  bool bufferOutput = true;

  @override
  int contentLength = -1;

  @override
  Encoding encoding = utf8;

  @override
  bool followRedirects = true;

  @override
  int maxRedirects = 5;

  @override
  bool persistentConnection = true;

  @override
  void abort([Object? exception, StackTrace? stackTrace]) {}

  @override
  void add(List<int> data) {}

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future addStream(Stream<List<int>> stream) async {}

  @override
  Future<HttpClientResponse> close() async {
    return _MockHttpClientResponse();
  }

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  List<Cookie> cookies = [];

  @override
  Future<HttpClientResponse> get done async => _MockHttpClientResponse();

  @override
  Future flush() async {}

  @override
  HttpHeaders get headers => _MockHttpHeaders();

  @override
  String get method => 'GET';

  @override
  Uri get uri => Uri.parse('http://localhost');

  @override
  void write(Object? object) {}

  @override
  void writeAll(Iterable objects, [String separator = ""]) {}

  @override
  void writeCharCode(int charCode) {}

  @override
  void writeln([Object? object = ""]) {}
}

class _MockHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  @override
  final int statusCode = 200;

  @override
  final String reasonPhrase = 'OK';

  @override
  final int contentLength = 58; // Length of the transparent image bytes

  @override
  final HttpHeaders headers = _MockHttpHeaders();

  @override
  final bool isRedirect = false;

  @override
  final List<RedirectInfo> redirects = [];

  @override
  final bool persistentConnection = true;

  @override
  final X509Certificate? certificate = null;

  @override
  final HttpConnectionInfo? connectionInfo = null;

  @override
  final HttpClientResponseCompressionState compressionState =
      HttpClientResponseCompressionState.notCompressed;

  @override
  List<Cookie> get cookies => [];

  @override
  Future<HttpClientResponse> redirect([
    String? method,
    Uri? url,
    bool? followLoops,
  ]) async {
    return this;
  }

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    // Return transparent 1x1 pixel png
    final List<int> transparentImage = [
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // Header
      0x00, 0x00, 0x00, 0x0D, // IHDR length
      0x49, 0x48, 0x44, 0x52, // IHDR type
      0x00, 0x00, 0x00, 0x01, // Width 1
      0x00, 0x00, 0x00, 0x01, // Height 1
      0x08, 0x06, 0x00, 0x00, 0x00, // Bit depth, color type, etc
      0x1F, 0x15, 0xC4, 0x89, // CRC
      0x00, 0x00, 0x00, 0x0A, // IDAT length
      0x49, 0x44, 0x41, 0x54, // IDAT type
      0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, // Data
      0x0D, 0x0A, 0x2D, 0xB4, // CRC
      0x00,
      0x00,
      0x00,
      0x00,
      0x49,
      0x45,
      0x4E,
      0x44,
      0xAE,
      0x42,
      0x60,
      0x82, // IEND
    ];

    return Stream<List<int>>.value(transparentImage).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  Future<Socket> detachSocket() async {
    throw UnsupportedError('Mock response does not support detachSocket');
  }
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  List<String>? operator [](String name) => null;

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  void clear() {}

  @override
  void forEach(void Function(String name, List<String> values) f) {}

  @override
  void noFolding(String name) {}

  @override
  void remove(String name, Object value) {}

  @override
  void removeAll(String name) {}

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  String? value(String name) => null;

  @override
  bool chunkedTransferEncoding = false;

  @override
  int contentLength = 0;

  @override
  ContentType? contentType;

  @override
  DateTime? date;

  @override
  DateTime? expires;

  @override
  String? host;

  @override
  DateTime? ifModifiedSince;

  @override
  bool persistentConnection = true;

  @override
  int? port;
}
