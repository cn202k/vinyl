import 'package:vinyl/vinyl.dart';
part 'user.vinyl.dart';

class Foo<T> {
  FooBuilder<T> toBuilder() => FooBuilder();
}

class FooBuilder<T> {
  Foo<T> build() => Foo();
}

@Vinyl(toBuilderMethod: 'toBuilder')
mixin User<T> {
  String get name;
  String get mail;
  int? get age => 0;
  int get size => 0;

  @Builder(FooBuilder)
  Foo<T>? get foo;

  List<String>? get favs;

  @getter
  int get sum => size * 2;

  UserBuilder<T> toBuilder();
}
