// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result.dart';

// **************************************************************************
// VinylGenerator
// **************************************************************************

abstract class ResultBuilder<T extends num, $T extends Result<T>>
    implements Builder<$T> {
  abstract int code;

  set source(covariant Result<T> value$);
  @override
  $T build();
}

extension $SealedResultApi<T extends num> on Result<T> {
  $R map<$R>(
      $R Function(Data<T> value) data, $R Function(Error<T> value) error) {
    final self = this;
    if (self is Data<T>) return data(self);
    if (self is Error<T>) return error(self);
    throw StateError("Unexpected type : ${self.runtimeType}");
  }

  $R? match<$R>(
      {$R? Function(Data<T> value)? data,
      $R? Function(Error<T> value)? error,
      $R? Function(Result<T> value)? otherwise}) {
    final self = this;
    if (self is Data<T>) {
      if (data != null) return data(self);
    } else if (self is Error<T>) {
      if (error != null) return error(self);
    }

    return otherwise?.call(self);
  }

  $R? apply<$R, $U extends Result<T>>($R Function($U value) function) {
    final self = this;
    return (self is $U) ? function(self) : null;
  }

  bool get isData => this is Data<T>;
  bool get isError => this is Error<T>;
  Data<T>? get asData {
    final self = this;
    return self is Data<T> ? self : null;
  }

  Error<T>? get asError {
    final self = this;
    return self is Error<T> ? self : null;
  }
}

class _$Data<T extends num> with Data<T> {
  _$Data({required this.code, required this.value});

  @override
  final int code;

  @override
  final T value;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is Data<T> &&
            (identical(other.code, code) ||
                const DeepCollectionEquality().equals(other.code, code)) &&
            (identical(other.value, value) ||
                const DeepCollectionEquality().equals(other.value, value)) &&
            super == other);
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(code) ^
      const DeepCollectionEquality().hash(value) ^
      super.hashCode;
  @override
  String toString() => 'Data(code: $code, value: $value)';
  @override
  DataBuilder<T> call() => DataBuilder<T>(code, value);
}

Data<T> newData<T extends num>({required int code, required T value}) =>
    _$Data(code: code, value: value);

class DataBuilder<T extends num> implements ResultBuilder<T, Data<T>> {
  DataBuilder(this.code, this.value);

  @override
  int code;

  @override
  T value;

  set source(Data<T> value$) {
    code = value$.code;
    value = value$.value;
  }

  @override
  Data<T> build() => _$Data<T>(code: code, value: value);
}

class _$Error<T extends num> with Error<T> {
  _$Error({required this.code, required this.message});

  @override
  final int code;

  @override
  final String message;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is Error<T> &&
            (identical(other.code, code) ||
                const DeepCollectionEquality().equals(other.code, code)) &&
            (identical(other.message, message) ||
                const DeepCollectionEquality()
                    .equals(other.message, message)) &&
            super == other);
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(code) ^
      const DeepCollectionEquality().hash(message) ^
      super.hashCode;
  @override
  String toString() => 'Error(code: $code, message: $message)';
  @override
  ErrorBuilder<T> call() => ErrorBuilder<T>(code, message);
}

Error<T> newError<T extends num>(
        {required int code, required String message}) =>
    _$Error(code: code, message: message);

class ErrorBuilder<T extends num> implements ResultBuilder<T, Error<T>> {
  ErrorBuilder(this.code, this.message);

  @override
  int code;

  @override
  String message;

  set source(Error<T> value$) {
    code = value$.code;
    message = value$.message;
  }

  @override
  Error<T> build() => _$Error<T>(code: code, message: message);
}
