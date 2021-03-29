import 'package:example/user.dart';
import 'package:vinyl/vinyl.dart';

void main() {
  final user = vinyl.user<W>(
    gomgom: {},
    id: W(),
    name: 'gabi',
    mail: 'mail@gmail.com',
    foo: null,
    favs: null,
  );

  final user2 = copy(
    user.toBuilder()
      ..name = 'elen gabi'
      ..source = vinyl.user<W>(
        gomgom: {},
        id: W(),
        name: 'elen',
        mail: 'elen@wall.com',
        foo: null,
        favs: [],
      ),
  );
}
