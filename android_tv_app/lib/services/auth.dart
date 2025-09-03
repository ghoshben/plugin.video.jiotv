import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Manages authentication and header construction for JioTV requests.
class JioAuth {
  /// Headers used for general API calls like featured, channel list and EPG.
  Map<String, String> headers = {};

  final http.Client _client = http.Client();

  /// Headers required when requesting a channel URL.
  Map<String, String> get channelHeaders => {
        'ssoToken': headers['ssotoken'] ?? '',
        'userId': headers['userid'] ?? '',
        'uniqueId': headers['uniqueid'] ?? '',
        'crmid': headers['crmid'] ?? '',
        'user-agent':
            'plaYtv/7.1.5 (Linux;Android 9) ExoPlayerLib/2.11.7',
        'deviceid': headers['deviceId'] ?? '',
        'devicetype': 'phone',
        'os': 'B2G',
        'osversion': '2.5',
        'versioncode': '353',
      };

  /// Performs username/password authentication mirroring the Kodi add-on.
  Future<bool> loginWithPassword(String username, String password) async {
    final body = {
      'identifier': username.contains('@') ? username : '+91$username',
      'password': password,
      'rememberUser': 'T',
      'upgradeAuth': 'Y',
      'returnSessionDetails': 'T',
      'deviceInfo': {
        'consumptionDeviceName': 'ZUK Z1',
        'info': {
          'type': 'android',
          'platform': {'name': 'ham', 'version': '8.0.0'},
          'androidId': _randomUuid(),
        }
      }
    };

    final resp = await _client.post(
      Uri.parse('https://api.jio.com/v3/dip/user/unpw/verify'),
      headers: {
        'User-Agent': 'JioTV',
        'x-api-key': 'l7xx75e822925f184370b2e25170c5d5820a',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      if ((data['ssoToken'] ?? '').toString().isNotEmpty) {
        _buildHeaders(data);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('headers', jsonEncode(headers));
        return true;
      }
    }
    return false;
  }

  /// Performs OTP based authentication.
  Future<bool> loginWithOtp(String mobile, String otp) async {
    final body = {
      'number': base64Encode(utf8.encode('+91$mobile')),
      'otp': otp,
      'deviceInfo': {
        'consumptionDeviceName': 'unknown sdk_google_atv_x86',
        'info': {
          'type': 'android',
          'platform': {'name': 'generic_x86'},
          'androidId': _randomUuid(),
        }
      }
    };

    final resp = await _client.post(
      Uri.parse(
          'https://jiotvapi.media.jio.com/userservice/apis/v1/loginotp/verify'),
      headers: {
        'User-Agent': 'okhttp/4.2.2',
        'devicetype': 'phone',
        'os': 'android',
        'appname': 'RJIL_JioTV',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      if ((data['ssoToken'] ?? '').toString().isNotEmpty) {
        _buildHeaders(data);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('headers', jsonEncode(headers));
        return true;
      }
    }
    return false;
  }

  /// Loads previously saved headers from persistent storage.
  Future<void> loadSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('headers');
    if (raw != null) {
      headers = Map<String, String>.from(jsonDecode(raw));
    }
  }

  /// Helper to build request headers from login response.
  void _buildHeaders(Map<String, dynamic> resp) {
    headers = {
      'appName': 'RJIL_JioTV',
      'deviceId': resp['deviceId']?.toString() ?? '',
      'devicetype': 'phone',
      'os': 'android',
      'osversion': '9',
      'partner': 'jiotvvod',
      'user-agent':
          'plaYtv/7.1.5 (Linux;Android 9) ExoPlayerLib/2.11.7',
      'usergroup': 'tvYR7NSNn7rymo3F',
      'versioncode': '343',
      'platform': 'ANDROID_PHONE',
      'dm': 'ZUK ZUK Z1',
      'authtoken': resp['authToken']?.toString() ?? '',
      'ssotoken': resp['ssoToken']?.toString() ?? '',
      'userid':
          resp['sessionAttributes']?['user']?['uid']?.toString() ?? '',
      'uniqueid':
          resp['sessionAttributes']?['user']?['unique']?.toString() ?? '',
      'crmid': resp['sessionAttributes']?['user']?['subscriberId']?.toString() ?? '',
      'subscriberid':
          resp['sessionAttributes']?['user']?['subscriberId']?.toString() ?? '',
      'jtoken': resp['jToken']?.toString() ?? '',
    };
  }

  /// Very small helper to mimic uuid4 without extra dependency.
  String _randomUuid() => DateTime.now().millisecondsSinceEpoch.toString();
}


