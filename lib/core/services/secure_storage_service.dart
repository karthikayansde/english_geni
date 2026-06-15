import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class ISecureStorage {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
  Future<void> deleteAll();
  Future<bool> containsKey(String key);
}

class SecureStorageService implements ISecureStorage {
  final _storage = const FlutterSecureStorage();

  @override
  Future<void> write(String key, String value) async => await _storage.write(key: key, value: value);

  @override
  Future<String?> read(String key) async => await _storage.read(key: key);

  @override
  Future<void> delete(String key) async => await _storage.delete(key: key);

  @override
  Future<void> deleteAll() async => await _storage.deleteAll();

  @override
  Future<bool> containsKey(String key) async => await _storage.containsKey(key: key);

}
