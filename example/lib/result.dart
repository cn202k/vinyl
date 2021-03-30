import 'package:vinyl/vinyl.dart';
part 'result.vinyl.dart';

@vinyl
mixin Result<T> {
  static final data = newData;
  static final error = newError;

  int get code;

  ResultBuilder<T, Result<T>> call();
}

@vinyl
mixin Data<T> implements Result<T> {
  T get value;

  DataBuilder<T> call();
}

@vinyl
mixin Error<T> implements Result<T> {
  String get message;

  ErrorBuilder<T> call();
}
