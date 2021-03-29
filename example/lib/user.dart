import 'package:vinyl/vinyl.dart';

import 'example.dart';
part 'user.vinyl.dart';

class Foo<T> {
  FooBuilder<T> toBuilder() => FooBuilder();
}

class FooBuilder<T> {
  Foo<T> build() => Foo();
}

abstract class Interface<T> extends GomGom<int> {
  T get id;
}

class W {}

@Vinyl(toBuilderMethod: 'toBuilder')
mixin User<T extends W> implements Interface<T> {
  String get name;
  String get mail;
  int? get age => 0;
  int get size => 0;

  @Builder(FooBuilder)
  Foo<T>? get foo;

  List<String>? get favs;

  @lazy
  int get sum => size * 2;

  UserBuilder<T> toBuilder();
}
