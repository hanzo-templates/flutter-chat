import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// The whole Hanzo integration: one streaming call to /v1/chat/completions.
///
/// Config is read at RUNTIME (Settings) rather than baked in with
/// --dart-define, because a compiled-in key ships inside every copy of the app.
/// Ship the app, let the user bring the key.
class Msg {
  const Msg(this.role, this.content);
  final String role;
  final String content;
  Map<String, String> toJson() => {'role': role, 'content': content};
}

class Hanzo {
  Hanzo._();
  static final Hanzo instance = Hanzo._();

  String base = 'https://api.hanzo.ai/v1';
  String model = 'zen-omni';
  String key = '';

  /// Yields the assistant reply token by token. The caller appends each chunk;
  /// nothing here knows about widgets.
  Stream<String> complete(List<Msg> messages) async* {
    if (key.isEmpty) {
      throw StateError('No API key. Open Settings and paste a Hanzo key.');
    }

    final req = http.Request('POST', Uri.parse('$base/chat/completions'))
      ..headers.addAll({'Content-Type': 'application/json', 'Authorization': 'Bearer $key'})
      ..body = jsonEncode({
        'model': model,
        'messages': messages.map((m) => m.toJson()).toList(),
        'stream': true,
      });

    final res = await req.send();
    if (res.statusCode != 200) {
      throw http.ClientException('${res.statusCode} ${await res.stream.bytesToString()}');
    }

    // LineSplitter reassembles SSE frames that arrive split across chunks.
    await for (final line in res.stream.transform(utf8.decoder).transform(const LineSplitter())) {
      if (!line.startsWith('data:')) continue;
      final payload = line.substring(5).trim();
      if (payload == '[DONE]') return;
      try {
        final delta = (jsonDecode(payload)['choices'] as List).first['delta']['content'];
        if (delta is String && delta.isNotEmpty) yield delta;
      } catch (_) {
        // keep-alive comment or a frame we do not model — skip it
      }
    }
  }
}
