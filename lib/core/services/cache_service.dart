import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class CacheService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Map<String, dynamic> _memoryCache = {};

  Future<void> setCache(String key, dynamic value, {Duration? expiry}) async {
    try {
      final cacheData = {
        'value': value,
        'timestamp': DateTime.now().toIso8601String(),
        'expiry': expiry?.add(DateTime.now()).toIso8601String(),
      };
      
      // Store in memory cache
      _memoryCache[key] = cacheData;
      
      // Store in persistent storage
      await _storage.write(key: 'cache_$key', value: jsonEncode(cacheData));
    } catch (e) {
      // Handle error
    }
  }

  Future<T?> getCache<T>(String key) async {
    try {
      // Check memory cache first
      if (_memoryCache.containsKey(key)) {
        final cacheData = _memoryCache[key];
        if (!_isExpired(cacheData)) {
          return cacheData['value'] as T?;
        } else {
          _memoryCache.remove(key);
        }
      }
      
      // Check persistent storage
      final cachedData = await _storage.read(key: 'cache_$key');
      if (cachedData != null) {
        final cacheData = jsonDecode(cachedData);
        if (!_isExpired(cacheData)) {
          _memoryCache[key] = cacheData;
          return cacheData['value'] as T?;
        } else {
          await _storage.delete(key: 'cache_$key');
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> removeCache(String key) async {
    _memoryCache.remove(key);
    await _storage.delete(key: 'cache_$key');
  }

  Future<void> clearCache() async {
    _memoryCache.clear();
    // In a real app, you'd iterate through all cache keys
  }

  bool _isExpired(Map<String, dynamic> cacheData) {
    if (cacheData['expiry'] == null) return false;
    final expiry = DateTime.parse(cacheData['expiry']);
    return DateTime.now().isAfter(expiry);
  }

  bool isOnline() {
    // Mock implementation - in a real app, you'd check network connectivity
    return true;
  }
}
