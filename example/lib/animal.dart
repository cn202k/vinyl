import 'package:vinyl/vinyl.dart';

@vinyl
mixin Os {
  String get name;
  int get version;
}

@vinyl
mixin Android implements Os {
  String get codeName;
}

@vinyl
mixin Ios implements Os {
  String get architecture;
}
