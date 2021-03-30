import 'package:example/user.dart';
import 'package:vinyl/vinyl.dart';

void main() {
  final user = User.of<W>(
    gomgom: {},
    id: W(),
    name: 'gabi',
    mail: 'mail@gmail.com',
    foo: null,
    favs: null,
  );

  final us = newUser<W>(
    gomgom: {},
    id: W(),
    name: 'gabi',
    mail: 'mail@gmail.com',
    foo: null,
    favs: null,
  );

  final uss = User.of<W>(
    gomgom: {},
    id: W(),
    name: 'gabi',
    mail: 'mail@gmail.com',
    foo: null,
    favs: null,
  );

  final user2 = copy(user.toBuilder()
    ..name = 'elen gabi'
    ..source = User.of<W>(
      gomgom: {},
      id: W(),
      name: 'elen',
      mail: 'elen@wall.com',
      foo: null,
      favs: [],
    ));
  final s = User.of(
    name: 'f',
    mail: '',
    foo: null,
    favs: null,
    gomgom: {},
    id: W(),
  );
}
