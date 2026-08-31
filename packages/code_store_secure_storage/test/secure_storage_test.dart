import 'package:code_store_secure_storage/code_store_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class MockSecureStorageService implements ISecureStorageService {
  final Map<String, String> _vault = {};

  @override
  Future<String?> read({required String key}) async => _vault[key];

  @override
  Future<void> write({required String key, required String value}) async {
    _vault[key] = value;
  }

  @override
  Future<void> delete({required String key}) async {
    _vault.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _vault.clear();
  }

  @override
  Future<Map<String, String>> readAll() async => Map.unmodifiable(_vault);

  @override
  Future<bool> containsKey({required String key}) async =>
      _vault.containsKey(key);

  @override
  Future<int?> readInt(String key) async {
    final val = await read(key: key);
    return val != null ? int.tryParse(val) : null;
  }

  @override
  Future<void> writeInt(String key, int value) async {
    await write(key: key, value: value.toString());
  }

  @override
  Future<bool?> readBool(String key) async {
    final val = await read(key: key);
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
    return null;
  }

  @override
  Future<void> writeJson(String key, Map<String, dynamic> json) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureStorage DI & Operations', () {
    final sl = GetIt.asNewInstance();

    test('setupSecureStorageDI registers mock correctly', () {
      final mock = MockSecureStorageService();
      setupSecureStorageDI(locator: sl, customService: mock);

      expect(sl.isRegistered<ISecureStorageService>(), true);
      expect(sl<ISecureStorageService>(), isA<MockSecureStorageService>());
    });

    test('MockSecureStorage CRUD operations work', () async {
      final service = MockSecureStorageService();

      await service.write(key: 'auth_token', value: 'secret_123');
      expect(await service.read(key: 'auth_token'), 'secret_123');
      expect(await service.containsKey(key: 'auth_token'), true);

      await service.writeInt('user_id', 42);
      expect(await service.readInt('user_id'), 42);

      await service.writeBool('is_premium', true);
      expect(await service.readBool('is_premium'), true);

      await service.delete(key: 'auth_token');
      expect(await service.read(key: 'auth_token'), isNull);

      await service.deleteAll();
      expect(await service.readAll(), isEmpty);
    });
  });
}
