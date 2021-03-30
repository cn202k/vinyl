import 'package:vinyl/vinyl.dart';

mixin Result<T> {
  int get code;

  ResultBuilder<T, Result<T>> toBuilder();
}

mixin Successful<T> implements Result<T> {
  T get value;

  @override
  SuccessfulBuilder<T> toBuilder();
}

mixin Error<T> implements Result<T> {
  String get message;

  @override
  ErrorBuilder<T> toBuilder();
}

abstract class ResultBuilder<T, $T extends Result<T>>
    implements Builder<$T> {
  set code(int value);

  set source(covariant Result<T> value);

  @override
  $T build();
}

class SuccessfulBuilder<T> implements ResultBuilder<T, Successful<T>> {
  @override
  set code(int value) {
    // TODO: implement code
  }

  @override
  set source(Successful<T> value) {
    // TODO: implement source
  }

  @override
  Successful<T> build() => throw UnimplementedError();
}

class ErrorBuilder<T> implements ResultBuilder<T, Error<T>> {
  @override
  set code(int value) {
    // TODO: implement code
  }

  @override
  set source(Successful<T> value) {
    // TODO: implement source
  }

  @override
  Error<T> build() => throw UnimplementedError();
}
