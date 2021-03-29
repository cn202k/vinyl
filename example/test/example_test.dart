import 'package:example/user.dart';
import 'package:vinyl/vinyl.dart';

void main() {
  final user = vinyl.user<int>(
    name: 'gabi',
    mail: 'mail@gmail.com',
    foo: null,
    favs: null,
  );

  final user2 = copy(
    user.toBuilder()
      ..name = 'elen gabi'
      ..source = vinyl.user<int>(
        name: 'elen',
        mail: 'elen@wall.com',
        foo: null,
        favs: [],
      ),
  );
}
