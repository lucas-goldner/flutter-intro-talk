import 'package:flutter/foundation.dart';
import 'package:flutter_intro_talk/demo_app/layer_trace.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// ApiClient — only knows about HTTP and JSON.
abstract interface class ApiClient {
  Future<Object?> get(String path);
  Future<void> put(String path, Map<String, Object?> body);
}

/// Switches on the slide: 「遅いネットワーク」「エラーを起こす」.
class NetworkSettings extends ChangeNotifier {
  bool _slow = false;
  bool _fail = false;

  bool get slow => _slow;
  bool get fail => _fail;

  set slow(bool value) {
    _slow = value;
    notifyListeners();
  }

  set fail(bool value) {
    _fail = value;
    notifyListeners();
  }
}

/// An in-memory server standing in for a real HTTP API.
class FakeApiClient implements ApiClient {
  FakeApiClient(this._settings, this._trace);

  final NetworkSettings _settings;
  final LayerTrace _trace;

  final _favorites = <String>{'2'};

  static const _events = [
    ('1', 'Flutter Tokyo #42', '2026-12-03T19:00:00', '渋谷'),
    ('2', 'FlutterKaigi 2026 振り返り会', '2026-12-10T19:30:00', '五反田'),
    ('3', 'Dart もくもく会', '2026-12-14T13:00:00', 'オンライン'),
    ('4', 'Flutter × AI ハンズオン', '2026-12-20T14:00:00', '品川'),
    ('5', '年末 LT 大会', '2026-12-26T18:30:00', '新宿'),
    ('6', 'Riverpod 読書会', '2027-01-09T19:00:00', '秋葉原'),
  ];

  Future<void> _network() =>
      Future<void>.delayed(Duration(milliseconds: _settings.slow ? 2600 : 700));

  @override
  Future<Object?> get(String path) async {
    _trace
      ..add(Layer.apiClient, TraceFlow.down, 'GET /$path')
      ..add(Layer.server, TraceFlow.down, 'HTTP リクエスト');
    await _network();
    if (_settings.fail) {
      _trace
        ..add(Layer.server, TraceFlow.error, '500 Internal Server Error')
        ..add(Layer.apiClient, TraceFlow.error, 'throw ApiException');
      throw const ApiException(500, 'Internal Server Error');
    }
    _trace
      ..add(Layer.server, TraceFlow.up, '200 OK')
      ..add(Layer.apiClient, TraceFlow.up, 'jsonDecode → JSON');
    return [
      for (final (id, title, startsAt, venue) in _events)
        {
          'id': id,
          'title': title,
          'starts_at': startsAt,
          'venue': venue,
          'is_favorite': _favorites.contains(id),
        },
    ];
  }

  @override
  Future<void> put(String path, Map<String, Object?> body) async {
    _trace
      ..add(Layer.apiClient, TraceFlow.down, 'PUT /$path')
      ..add(Layer.server, TraceFlow.down, 'HTTP リクエスト');
    await _network();
    if (_settings.fail) {
      _trace
        ..add(Layer.server, TraceFlow.error, '500 Internal Server Error')
        ..add(Layer.apiClient, TraceFlow.error, 'throw ApiException');
      throw const ApiException(500, 'Internal Server Error');
    }
    final id = path.split('/')[1];
    if (body['value'] == true) {
      _favorites.add(id);
    } else {
      _favorites.remove(id);
    }
    _trace
      ..add(Layer.server, TraceFlow.up, '204 No Content')
      ..add(Layer.apiClient, TraceFlow.up, '完了');
  }
}

/// Overridden by the slide with a [FakeApiClient].
final apiClientProvider = Provider<ApiClient>(
  (ref) => throw UnimplementedError('apiClientProvider must be overridden'),
);
