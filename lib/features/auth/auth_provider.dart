import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import '../../core/api/subsonic_api.dart';
import 'package:flutter/material.dart';

class AuthState extends ChangeNotifier {
  final SubsonicApi _api;
  bool _isConnected = false;
  bool _isLoading = false;
  String? _error;
  String? _serverUrl;
  String? _username;

  AuthState(this._api);

  SubsonicApi get api => _api;
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get serverUrl => _serverUrl;
  String? get username => _username;

  Future<void> init() async {
    await _loadSession();
    if (_api.isConnected) {
      final ok = await _api.ping();
      if (ok) {
        _isConnected = true;
        notifyListeners();
      } else {
        _api.logout();
        _clearSaved();
      }
    }
  }

  Future<bool> login(String url, String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final ok = await _api.login(url, username, password);
      if (ok) {
        _isConnected = true;
        _serverUrl = url;
        _username = username;
        _isLoading = false;
        await _saveSession();
        notifyListeners();
        return true;
      } else {
        _error = '无法连接到服务器，请检查地址和凭证';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '连接失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _api.logout();
    _isConnected = false;
    _serverUrl = null;
    _username = null;
    await _clearSaved();
    notifyListeners();
  }

  Future<void> _saveSession() async {
    try {
      final dir = await path_provider.getApplicationDocumentsDirectory();
      final file = File('${dir.path}/session.json');
      await file.writeAsString(jsonEncode({
        'serverUrl': _serverUrl,
        'username': _username,
        'password': _api.password,
      }));
    } catch (_) {}
  }

  Future<void> _loadSession() async {
    try {
      final dir = await path_provider.getApplicationDocumentsDirectory();
      final file = File('${dir.path}/session.json');
      if (await file.exists()) {
        final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
        _api.setCredentials(
          data['serverUrl'] as String,
          data['username'] as String,
          data['password'] as String,
        );
      }
    } catch (_) {}
  }

  Future<void> _clearSaved() async {
    try {
      final dir = await path_provider.getApplicationDocumentsDirectory();
      final file = File('${dir.path}/session.json');
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }
}
