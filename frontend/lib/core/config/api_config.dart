import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Centralized API configuration.
///
/// The released APK runs away from the backend's network — the backend lives on
/// a dev machine exposed through a permanent ngrok tunnel — so the tunnel URL is
/// the only address that can ever work in a real demo. LAN and loopback
/// candidates are therefore probed in debug builds only: a release build must
/// never lock onto a LAN address it has no way to reach.
class ApiConfig {
  static String? _cachedBaseUrl;

  static const String _unconfiguredRemote =
      'https://REPLACE-WITH-YOUR-DOMAIN.example.com';

  /// Primary backend: the always-on cloud deployment on Railway. Needs no
  /// laptop, no tunnel, and nothing running locally.
  ///
  /// Override at build time without editing this file:
  ///   flutter build apk --release --dart-define=API_BASE_URL=https://your.domain
  static const String remoteBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://hunarsetu-production.up.railway.app',
  );

  /// Fallback: the dev laptop behind a reserved ngrok tunnel. Only reachable
  /// while that tunnel is running. Probed after Railway, so it costs nothing
  /// when the cloud backend is healthy but rescues a demo if it is not.
  static const String tunnelBaseUrl =
      'https://natantly-questionless-barabara.ngrok-free.dev';

  /// LAN address of the dev machine. Only reachable while the phone is on the
  /// same Wi-Fi, so it serves local development and is never used in release.
  static const String hostLanIp = '192.168.1.5';

  /// True once [remoteBaseUrl] points at a real tunnel.
  static bool get isRemoteConfigured =>
      remoteBaseUrl.isNotEmpty && remoteBaseUrl != _unconfiguredRemote;

  /// Headers every request to the backend must carry.
  ///
  /// `ngrok-skip-browser-warning` opts out of ngrok's free-tier interstitial,
  /// which answers with HTTP 200 and an HTML body — indistinguishable from a
  /// healthy response by status code alone, and fatal to JSON decoding.
  /// A fresh map is returned on each access because Dio mutates request headers.
  static Map<String, String> get defaultHeaders => <String, String>{
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      };

  /// [defaultHeaders] plus any request-specific additions.
  static Map<String, String> headersWith([
    Map<String, String> extra = const <String, String>{},
  ]) =>
      <String, String>{...defaultHeaders, ...extra};

  static String get baseUrl => _cachedBaseUrl ?? _resolveInitialBaseUrl();

  static void setBaseUrl(String url) {
    _cachedBaseUrl = _normalize(url);
    debugPrint('[ApiConfig] Base URL manually set to: $_cachedBaseUrl');
  }

  static String _normalize(String url) =>
      url.endsWith('/') ? url.substring(0, url.length - 1) : url;

  static String _resolveInitialBaseUrl() {
    if (isRemoteConfigured) return _normalize(remoteBaseUrl);
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'http://$hostLanIp:8000'
          : 'http://127.0.0.1:8000';
    }
    // Nothing better to offer. Returning a LAN IP from a release build would
    // only produce confusing timeouts once the phone leaves the dev network.
    return _normalize(remoteBaseUrl);
  }

  /// Candidates in priority order: the cloud backend, then the laptop tunnel,
  /// then local addresses. The local ones are debug-only, so a release APK
  /// never caches a LAN IP it has no route to.
  static List<String> _candidates() => <String>[
        if (isRemoteConfigured) _normalize(remoteBaseUrl),
        if (_normalize(remoteBaseUrl) != tunnelBaseUrl) tunnelBaseUrl,
        if (kDebugMode) ...<String>[
          if (Platform.isAndroid) 'http://10.0.2.2:8000',
          'http://$hostLanIp:8000',
          'http://127.0.0.1:8000',
        ],
      ];

  /// Probes `/api/v1/health` on each candidate and locks onto the first one
  /// that returns a genuine health payload.
  static Future<String> discoverWorkingUrl() async {
    for (final candidate in _candidates()) {
      if (await _isHealthy(candidate)) {
        debugPrint('[ApiConfig] Discovered active backend at: $candidate');
        _cachedBaseUrl = candidate;
        return candidate;
      }
    }

    _cachedBaseUrl = _resolveInitialBaseUrl();
    debugPrint('[ApiConfig] No backend answered; defaulting to: $_cachedBaseUrl');
    return _cachedBaseUrl!;
  }

  static Future<bool> _isHealthy(String candidate) async {
    // A tunnelled round trip over mobile data needs far more headroom than a
    // LAN hop, the TLS handshake included.
    final timeout = candidate.startsWith('https://')
        ? const Duration(seconds: 8)
        : const Duration(milliseconds: 1500);

    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: timeout,
          receiveTimeout: timeout,
          headers: defaultHeaders,
        ),
      );
      final response = await dio.get('$candidate/api/v1/health');
      if (response.statusCode != 200) return false;

      // A 200 is not sufficient: ngrok interstitials and captive portals both
      // answer 200 with HTML. Require the health endpoint's actual payload.
      Map<String, dynamic>? payload;
      final data = response.data;
      if (data is Map) {
        payload = data.cast<String, dynamic>();
      } else if (data is String) {
        final decoded = jsonDecode(data);
        if (decoded is Map) payload = decoded.cast<String, dynamic>();
      }
      return payload != null && payload['status'] == 'healthy';
    } catch (_) {
      return false;
    }
  }
}
