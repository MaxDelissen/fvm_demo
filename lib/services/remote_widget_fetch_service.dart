import 'package:http/http.dart' as http;

/// Handles the raw HTTP download of remote widget libraries.
///
/// Keeping this separate from the RFW-specific service makes it clear which
/// code deals with networking vs. runtime parsing.
class RemoteWidgetFetchService {
  RemoteWidgetFetchService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  /// Returns the raw `.rfwtxt` contents for the given [uri].
  Future<String> fetchLibrary(Uri uri) async {
    final http.Response response;
    try {
      response = await _client.get(uri);
    } catch (error) {
      throw RemoteWidgetLoadException(
        'Failed to reach remote widget server: $error',
      );
    }

    if (response.statusCode != 200) {
      throw RemoteWidgetLoadException(
        'Remote server responded with HTTP ${response.statusCode}',
      );
    }

    return response.body;
  }
}

class RemoteWidgetLoadException implements Exception {
  RemoteWidgetLoadException(this.message);

  final String message;

  @override
  String toString() => 'RemoteWidgetLoadException: $message';
}
