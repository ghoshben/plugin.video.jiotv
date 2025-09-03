import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'auth.dart';

class JioApi {
  JioApi(this._auth);
  final JioAuth _auth;
  final http.Client _client = http.Client();

  Future<List<dynamic>> fetchFeatured() async {
    final resp =
        await _client.get(Uri.parse(JioConstants.featuredSrc), headers: _auth.headers);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return data['featuredNewData'] ?? [];
    }
    return [];
  }

  Future<List<dynamic>> fetchChannels() async {
    final resp = await _client.get(Uri.parse(JioConstants.channelsSrc), headers: _auth.headers);
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return data['result'] ?? [];
    }
    return [];
  }

  Future<List<dynamic>> fetchChannelsBy(String key, String value) async {
    final list = await fetchChannels();
    return list.where((ch) => (ch[key] as String?)?.contains(value) ?? false).toList();
  }

  Future<String?> resolveChannelUrl(int channelId,
      {String? showtime,
      String? srno,
      String? programId,
      String? begin,
      String? end}) async {
    final payload = {
      'channel_id': channelId,
      'stream_type': 'Seek',
    };
    if (showtime != null) payload['showtime'] = showtime;
    if (srno != null) payload['srno'] = srno;
    if (programId != null) payload['programId'] = programId;
    if (begin != null) payload['begin'] = begin;
    if (end != null) payload['end'] = end;

    final resp = await _client.post(Uri.parse(JioConstants.getChannelUrl),
        headers: _auth.channelHeaders, body: jsonEncode(payload));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return data['result'];
    }
    return null;
  }

  Future<List<dynamic>> fetchEpg(int channelId, {int offset = 0}) async {
    final url = JioConstants.catchupSrc
        .replaceFirst('{offset}', offset.toString())
        .replaceFirst('{channelId}', channelId.toString());
    final resp = await _client.get(Uri.parse(url), headers: _auth.headers);
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body)['result'] ?? [];
    }
    return [];
  }

  Future<Map<String, dynamic>> fetchDictionary() async {
    final resp = await _client.get(Uri.parse(JioConstants.dictionaryUrl), headers: _auth.headers);
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body)['result'] ?? {};
    }
    return {};
  }
}

