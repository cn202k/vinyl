import 'dart:math';

import 'package:vinyl/vinyl.dart';

abstract class SupLaz {
  int get sum => Random().nextInt(100);
}

class Laz extends SupLaz {
  dynamic _sum = vinyl;

  int get sum => (_sum == vinyl ? (_sum = super.sum) : _sum) as int;
}

class Goz extends SupLaz {}

void main() {
  final laz = Goz();
  print(laz.sum);
  print(laz.sum);
  print(laz.sum);
  print(laz.sum);
  print(laz.sum);
  print(laz.sum);
  print(laz.sum);
  print(laz.sum);
  print(laz.sum);
  print(laz.sum);
  print(laz.sum);
}
