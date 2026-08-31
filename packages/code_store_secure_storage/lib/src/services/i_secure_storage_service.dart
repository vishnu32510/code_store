/// Abstract contract for hardware-encrypted key-value secure storage.
abstract interface class ISecureStorageService {
  /// Reads a string value for the given [key]. Returns null if not found.
  Future<String?> read({required String key});

  /// Writes a [value] for the given [key] into encrypted hardware storage.
  Future<void> write({required String key, required String value});

  /// Deletes the entry for the given [key].
  Future<void> delete({required String key});

  /// Deletes all stored encrypted keys and values.
  Future<void> deleteAll();

  /// Retrieves all key-value pairs stored in the secure vault.
  Future<Map<String, String>> readAll();

  /// Returns whether a [key] exists in the secure storage.
  Future<bool> containsKey({required String key});

  /// Reads and parses an integer value.
  Future<int?> readInt(String key);

  /// Writes an integer value.
  Future<void> writeInt(String key, int value);

  /// Reads and parses a boolean value.
  Future<bool?> readBool(String key);

  /// Writes a boolean value.
  Future<void> writeBool(String key, bool value);

  /// Reads and parses a JSON object.
  Future<T?> readJson<T>(
    String key,
    T Function(Map<String, dynamic> json) fromJson,
  );

  /// Serializes and writes a JSON object.
  Future<void> writeJson(String key, Map<String, dynamic> json);
}
