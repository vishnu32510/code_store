import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'i_secure_storage_service.dart';

/// Concrete implementation of [ISecureStorageService] using [FlutterSecureStorage].
class SecureStorageService implements ISecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
                resetOnError: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
              mOptions: MacOsOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
              webOptions: WebOptions(
                dbName: 'CodeStoreSecureDB',
                publicKey: 'CodeStoreWebVault',
              ),
            );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read({required String key}) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      debugPrint('Error reading secure storage key "$key": $e');
      return null;
    }
  }

  @override
  Future<void> write({required String key, required String value}) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint('Error writing secure storage key "$key": $e');
    }
  }

  @override
  Future<void> delete({required String key}) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      debugPrint('Error deleting secure storage key "$key": $e');
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('Error deleting all secure storage keys: $e');
    }
  }

  @override
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      debugPrint('Error reading all secure storage keys: $e');
      return {};
    }
  }

  @override
  Future<bool> containsKey({required String key}) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      debugPrint('Error checking containsKey "$key": $e');
      return false;
    }
  }

  @override
  Future<int?> readInt(String key) async {
    final val = await read(key: key);
    if (val == null) return null;
    return int.tryParse(val);
  }

  @override
  Future<void> writeInt(String key, int value) async {
    await write(key: key, value: value.toString());
  }

  @override
  Future<bool?> readBool(String key) async {
    final val = await read(key: key);
    if (val == null) return null;
    if (val == 'true') return true;
    if (val == 'false') return false;
    return null;
  }

  @override
  Future<void> writeBool(String key, bool value) async {
    await write(key: key, value: value.toString());
  }

  @override
  Future<T?> readJson<T>(
    String key,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    final raw = await read(key: key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return fromJson(decoded);
      }
      return null;
    } catch (e) {
      debugPrint('Error parsing JSON from secure storage for key "$key": $e');
      return null;
    }
  }

  @override
  Future<void> writeJson(String key, Map<String, dynamic> json) async {
    final raw = jsonEncode(json);
    await write(key: key, value: raw);
  }
}
