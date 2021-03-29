import 'package:analyzer/dart/element/type.dart';
import 'package:vinyl_generator/src/parser/class_parser.dart';

class InterfaceParser {
  final InterfaceType element;

  InterfaceParser(this.element);

  ClassParser definition() => ClassParser(element.element);

  Iterable<String>? typeArguments() =>
      element.typeArguments.map((it) => it.toString());
}
