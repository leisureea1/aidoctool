import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 本地存储服务
class StorageService {
  static const _keyApiKeys = 'api_keys';
  static const _keySelectedModelId = 'selected_model_id';
  static const _keySelectedSubModels = 'selected_sub_models';
  static const _keyCustomBaseUrl = 'custom_base_url';
  static const _keyCustomModel = 'custom_model';
  static const _keyCustomMaxTokens = 'custom_max_tokens';
  
  final SharedPreferences _prefs;
  
  StorageService(this._prefs);
  
  /// 保存 API Keys
  Future<void> saveApiKeys(Map<String, String> apiKeys) async {
    await _prefs.setString(_keyApiKeys, jsonEncode(apiKeys));
  }
  
  /// 读取 API Keys
  Map<String, String> loadApiKeys() {
    final json = _prefs.getString(_keyApiKeys);
    if (json == null) return {};
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      return {};
    }
  }
  
  /// 保存选中的模型 ID
  Future<void> saveSelectedModelId(String modelId) async {
    await _prefs.setString(_keySelectedModelId, modelId);
  }
  
  /// 读取选中的模型 ID
  String? loadSelectedModelId() {
    return _prefs.getString(_keySelectedModelId);
  }
  
  /// 保存子模型选择
  Future<void> saveSelectedSubModels(Map<String, String> subModels) async {
    await _prefs.setString(_keySelectedSubModels, jsonEncode(subModels));
  }
  
  /// 读取子模型选择
  Map<String, String> loadSelectedSubModels() {
    final json = _prefs.getString(_keySelectedSubModels);
    if (json == null) return {};
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      return {};
    }
  }
  
  /// 保存自定义 API 配置
  Future<void> saveCustomConfig(String baseUrl, String model, int maxTokens) async {
    await _prefs.setString(_keyCustomBaseUrl, baseUrl);
    await _prefs.setString(_keyCustomModel, model);
    await _prefs.setInt(_keyCustomMaxTokens, maxTokens);
  }
  
  /// 读取自定义 API 地址
  String loadCustomBaseUrl() {
    return _prefs.getString(_keyCustomBaseUrl) ?? '';
  }
  
  /// 读取自定义模型名称
  String loadCustomModel() {
    return _prefs.getString(_keyCustomModel) ?? '';
  }
  
  /// 读取自定义 Max Tokens
  int loadCustomMaxTokens() {
    return _prefs.getInt(_keyCustomMaxTokens) ?? 30000;
  }
}
