import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jiotv_flutter/models/channel_model.dart';

class ChannelService {
  final String _channelsUrl =
      'https://jiotvapi.cdn.jio.com/apis/v3.0/getMobileChannelList/get/?langId=6&devicetype=phone&os=android&usertype=JIO&version=343';
  final String _getChannelUrl =
      'https://tv.media.jio.com/apis/v2.0/getchannelurl/getchannelurl?langId=6&userLanguages=All';
  final String _getSonyChannelUrl =
      'https://jiotvapi.media.jio.com/playback/apis/v1/geturl?langId=6';
  final _storage = const FlutterSecureStorage();

  static const _sonyChannelIds = [
    1401, 877, 477, 151, 154, 471, 181, 474, 182, 1775, 1773, 1772, 524, 892, 514, 183, 289, 291, 483
  ];

  Future<dynamic> getChannels() async {
    try {
      final response = await http.get(Uri.parse(_channelsUrl));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> channelList = responseData['result'];
        return channelList.map((json) => Channel.fromJson(json)).toList();
      } else {
        return 'Failed to fetch channels';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<dynamic> getChannelUrl(int channelId) async {
    try {
      final storedHeaders = await _storage.readAll();

      if (_sonyChannelIds.contains(channelId)) {
        return _getSonyUrl(channelId, storedHeaders);
      }

      final headers = {
        'ssotoken': storedHeaders['ssoToken'] ?? '',
        'userId': storedHeaders['userId'] ?? '',
        'uniqueId': storedHeaders['uniqueId'] ?? '',
        'crmid': storedHeaders['crmId'] ?? '',
        'user-agent': 'plaYtv/7.1.5 (Linux;Android 9) ExoPlayerLib/2.11.7',
        'deviceid': storedHeaders['deviceId'] ?? '',
        'devicetype': 'phone',
        'os': 'B2G',
        'osversion': '2.5',
        'versioncode': '353',
        'Content-Type': 'application/json',
      };

      final body = jsonEncode({
        'channel_id': channelId,
        'stream_type': 'Seek',
      });

      final response = await http.post(
        Uri.parse(_getChannelUrl),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final streamUrl = responseData['result'];
        final cookie = '__hdnea__${streamUrl.split('__hdnea__').last}';
        final streamHeaders = {
          'Cookie': cookie,
          'User-Agent': headers['user-agent']!,
        };
        return {'url': streamUrl, 'headers': streamHeaders};
      } else {
        return 'Failed to get channel URL';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<dynamic> _getSonyUrl(int channelId, Map<String, String> storedHeaders) async {
    final sonyHeaders = {
      'Host': 'jiotvapi.media.jio.com',
      'Appkey': 'NzNiMDhlYzQyNjJm',
      'Devicetype': 'phone',
      'Os': 'android',
      'Deviceid': storedHeaders['deviceId'] ?? '',
      'Osversion': '11',
      'Dm': 'Google Pixel 5',
      'Uniqueid': storedHeaders['deviceId'] ?? '',
      'Usergroup': 'tvYR7NSNn7rymo3F',
      'Languageid': '6',
      'Userid': storedHeaders['userId'] ?? '',
      'Sid': '892898ba-f9de-4572-b6c2-e717b0ad',
      'Crmid': storedHeaders['crmId'] ?? '',
      'Isott': 'false',
      'Channel_id': channelId.toString(),
      'ssoToken': storedHeaders['ssoToken'] ?? '',
      'Accesstoken': storedHeaders['authToken'] ?? '',
      'Subscriberid': storedHeaders['crmId'] ?? '',
      'analyticsId': storedHeaders['deviceId'] ?? '',
      'Lbcookie': '1',
      'Versioncode': '353',
      'Content-Type': 'application/x-www-form-urlencoded',
      'user-agent': 'jiotv',
      'Connection': 'keep-alive',
    };

    // Special handling for certain Sony channels, as per the original plugin's logic.
    final chan = (channelId == 154 || channelId == 471) ? '471' : channelId.toString();
    final body = 'stream_type=Seek&channel_id=$chan';

    final response = await http.post(
      Uri.parse(_getSonyChannelUrl),
      headers: sonyHeaders,
      body: body,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final streamUrl = responseData['result'];
      final cookie = '__hdnea__${streamUrl.split('__hdnea__').last}';
      final streamHeaders = {
        'Cookie': cookie,
        'User-Agent': sonyHeaders['user-agent']!,
      };
      return {'url': streamUrl, 'headers': streamHeaders};
    } else {
      return 'Failed to get Sony channel URL';
    }
  }
}
