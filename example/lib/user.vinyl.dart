// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// VinylGenerator
// **************************************************************************

class _$User<T extends W> with User<T> {
  _$User._(
      {required this.id,
      required this.gomgom,
      required this.name,
      required this.mail,
      required this.age,
      required this.size,
      required this.foo,
      required this.favs});

  factory _$User(
      {required T id,
      required Map<int, List<int>> gomgom,
      required String name,
      required String mail,
      int? age,
      int? size,
      required Foo<T>? foo,
      required List<String>? favs}) {
    final defaultUser = _$DefaultUser<T>();
    return _$User._(
        id: id,
        gomgom: gomgom,
        name: name,
        mail: mail,
        age: age ?? defaultUser.age,
        size: size ?? defaultUser.size,
        foo: foo,
        favs: favs);
  }

  @override
  final T id;

  @override
  final Map<int, List<int>> gomgom;

  @override
  final String name;

  @override
  final String mail;

  @override
  final int? age;

  @override
  final int size;

  @override
  final Foo<T>? foo;

  @override
  final List<String>? favs;

  dynamic _sum = vinyl;

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is User<T> &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.gomgom, gomgom) ||
                const DeepCollectionEquality().equals(other.gomgom, gomgom)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.mail, mail) ||
                const DeepCollectionEquality().equals(other.mail, mail)) &&
            (identical(other.age, age) ||
                const DeepCollectionEquality().equals(other.age, age)) &&
            (identical(other.size, size) ||
                const DeepCollectionEquality().equals(other.size, size)) &&
            (identical(other.foo, foo) ||
                const DeepCollectionEquality().equals(other.foo, foo)) &&
            (identical(other.favs, favs) ||
                const DeepCollectionEquality().equals(other.favs, favs)) &&
            super == other);
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(gomgom) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(mail) ^
      const DeepCollectionEquality().hash(age) ^
      const DeepCollectionEquality().hash(size) ^
      const DeepCollectionEquality().hash(foo) ^
      const DeepCollectionEquality().hash(favs) ^
      super.hashCode;
  @override
  String toString() =>
      'User(id: $id, gomgom: $gomgom, name: $name, mail: $mail, age: $age, size: $size, foo: $foo, favs: $favs)';
  @override
  int get sum => (_sum == vinyl ? (_sum = super.sum) : _sum) as int;
  @override
  UserBuilder<T> toBuilder() =>
      UserBuilder<T>(id, gomgom, name, mail, age, size, foo, favs);
}

User<T> newUser<T extends W>(
        {required T id,
        required Map<int, List<int>> gomgom,
        required String name,
        required String mail,
        int? age,
        int? size,
        required Foo<T>? foo,
        required List<String>? favs}) =>
    _$User(
        id: id,
        gomgom: gomgom,
        name: name,
        mail: mail,
        age: age,
        size: size,
        foo: foo,
        favs: favs);

class _$DefaultUser<T extends W> with User<T> {
  @override
  Never get id => throw UnimplementedError();
  @override
  Never get gomgom => throw UnimplementedError();
  @override
  Never get name => throw UnimplementedError();
  @override
  Never get mail => throw UnimplementedError();
  @override
  int? get age => super.age;
  @override
  int get size => super.size;
  @override
  Never get foo => throw UnimplementedError();
  @override
  Never get favs => throw UnimplementedError();
  @override
  Never toBuilder() => throw UnimplementedError();
}

class UserBuilder<T extends W> implements Builder<User<T>> {
  UserBuilder(this.id, this.gomgom, this.name, this.mail, this.age, this.size,
      Foo<T>? foo, this.favs)
      : foo = foo?.toBuilder();

  T id;

  Map<int, List<int>> gomgom;

  String name;

  String mail;

  int? age;

  int size;

  FooBuilder<T>? foo;

  List<String>? favs;

  set source(User<T> value) {
    id = value.id;
    gomgom = value.gomgom;
    name = value.name;
    mail = value.mail;
    age = value.age;
    size = value.size;
    foo = value.foo?.toBuilder();
    favs = value.favs;
  }

  @override
  User<T> build() => _$User<T>(
      id: id,
      gomgom: gomgom,
      name: name,
      mail: mail,
      age: age,
      size: size,
      foo: foo?.build(),
      favs: favs);
}
