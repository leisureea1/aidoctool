/// 统一失败类型定义
sealed class Failure {
  final String message;
  final String? details;
  
  const Failure(this.message, [this.details]);
}

/// 网络相关失败
class NetworkFailure extends Failure {
  final int? statusCode;
  
  const NetworkFailure(String message, {this.statusCode, String? details}) 
      : super(message, details);
}

/// AI API 调用失败
class AIApiFailure extends Failure {
  final String? errorCode;
  
  const AIApiFailure(String message, {this.errorCode, String? details}) 
      : super(message, details);
}

/// 解析失败
class ParseFailure extends Failure {
  const ParseFailure(super.message, [super.details]);
}

/// 配置失败
class ConfigFailure extends Failure {
  const ConfigFailure(super.message, [super.details]);
}

/// 存储失败
class StorageFailure extends Failure {
  const StorageFailure(super.message, [super.details]);
}

/// 未知失败
class UnknownFailure extends Failure {
  const UnknownFailure([String message = '发生未知错误']) : super(message);
}
