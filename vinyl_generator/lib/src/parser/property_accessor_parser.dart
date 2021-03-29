import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:source_gen/source_gen.dart';
import 'package:vinyl_generator/src/parser/class_parser.dart';

class PropertyAccessorParser {
  final PropertyAccessorElement element;

  PropertyAccessorParser(this.element);

  String name() => element.name;

  bool hasAnnotationOf(TypeChecker typeChecker) =>
      typeChecker.hasAnnotationOf(element);

  PropertyAccessorReturnTypeParser returnType() =>
      PropertyAccessorReturnTypeParser._(element);

  bool isAbstract() => element.isAbstract;
}

class PropertyAccessorReturnTypeParser {
  final PropertyAccessorElement _element;

  PropertyAccessorReturnTypeParser._(this._element);

  ClassParser? definition() {
    final type = _element.type.returnType.element;
    if (type is! ClassElement) return null;
    return ClassParser(type);
  }

  String source() => _element.type.returnType.toString();

  String name() => _element.type.returnType.element.name;

  String? typeArgumentsSource() {
    final src = source();
    var start = src.indexOf('<');
    var end = src.lastIndexOf('>');
    if (start < 0) return null;
    return src.substring(start + 1, end);
  }

  Iterable<String> typeArguments() {
    final src = typeArgumentsSource();
    if (src == null) return [];
    final text = '$src,';
    final args = <String>[];
    var depth = 0;
    var cursor = 0;
    for (var i = 0; i < text.length; ++i) {
      final char = text[i];
      if ('{[(<'.contains(char)) {
        depth += 1;
      } else if ('}])>'.contains(char)) {
        depth -= 1;
      } else if (char == ',' && depth == 0) {
        args.add(text.substring(cursor, i));
        cursor = i + 1;
      }
    }
    return args.map((it) => it.trim());
  }

  bool isNullable() =>
      _element.returnType.nullabilitySuffix == NullabilitySuffix.question;
}
