import 'package:example/idea.dart';

void main() {
  Result<int>? r = null;
  Result<int>? rr = null;
  Successful<int>? s = null;
  Error<int>? e = null;
  final builder = r!.toBuilder();
  builder.source = rr!;
  builder.source = s!;
  builder.source = e!;
  s.toBuilder().source = s;
}
