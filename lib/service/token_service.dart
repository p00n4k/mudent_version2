import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  // Add your storage service implementation here
  final storage = const FlutterSecureStorage();
  Future<void> writeToken(String token) async {
    await storage.write(key: 'token', value: token);
  }

  Future<String> readToken() async {
    final String token;
    token = await storage.read(key: 'token') ?? '';
    return token;
  }

  //clear token
  Future<void> deleteToken() async {
    await storage.delete(key: 'token');
  }
}
