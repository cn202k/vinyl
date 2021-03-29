import 'package:example/util.dart';

void main() {
  final x = ['', 'abc'];
  final y = x.map(
    (token) => token.mapIf(
      token.isNotEmpty,
      then: (_) => '@$token',
    ),
  );
  print(y.join(', '));
}
