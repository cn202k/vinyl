import 'package:example/result.dart';
import 'package:vinyl/vinyl.dart';

void main() {
  final data = Result.data(code: 404, value: 0.5);
  final Result<num> d = copy(data()
    ..code = 100
    ..value = 0.0);

  final String ret = d.map(
    (data) => '${data.value}',
    (error) => error.message,
  );

  d.match(
    error: (it) => print(it.message),
    otherwise: (it) => print(it.code),
  );

  final x = d.match(error: (it) => it.message);
  final v = d.asData?.value;

  final q = copy(d()..code = 100);

  final String? a = d.apply(doSomethingWithError);
}

String doSomethingWithError(Error<num> e) => e.message;
