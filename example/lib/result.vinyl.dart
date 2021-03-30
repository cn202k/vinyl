// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'result.dart';

// **************************************************************************
// VinylGenerator
// **************************************************************************

abstract class ResultBuilder<T, $T extends Result<T>> implements Builder<$T> {
  abstract int code;

  set source(covariant Result<T> value$);
  @override
  $T build();
}

class _$Data<T> with Data<T> {
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

Data<T> newData<T>({required int code, required T value}) =>
    _$Data(code: code, value: value);

class DataBuilder<T> implements ResultBuilder<T, Data<T>> {
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

class _$Error<T> with Error<T> {
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

Error<T> newError<T>({required int code, required String message}) =>
    _$Error(code: code, message: message);

class ErrorBuilder<T> implements ResultBuilder<T, Error<T>> {
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
