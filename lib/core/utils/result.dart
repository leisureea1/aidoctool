import '../errors/failures.dart';

/// Result 类型，用于统一处理成功和失败
sealed class Result<T> {
  const Result();
  
  /// 成功时执行
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  });
  
  /// 是否成功
  bool get isSuccess => this is Success<T>;
  
  /// 是否失败
  bool get isFailure => this is Failure;
  
  /// 获取数据（可能为 null）
  T? get dataOrNull => switch (this) {
    Success<T>(data: final data) => data,
    Error<T>() => null,
  };
  
  /// 获取失败（可能为 null）
  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    Error<T>(failure: final f) => f,
  };
}

/// 成功结果
class Success<T> extends Result<T> {
  final T data;
  
  const Success(this.data);
  
  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) => success(data);
}

/// 失败结果
class Error<T> extends Result<T> {
  final Failure failure;
  
  const Error(this.failure);
  
  @override
  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) => failure(this.failure);
}
