import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:vinyl_generator/src/parser/class_parser.dart';

import 'property_accessor_parser.dart';

class InterfaceParser {
  final InterfaceType element;

  InterfaceParser(this.element);

  ClassParser definition() => ClassParser(element.element);

  Iterable<String> typeArguments() =>
      element.typeArguments.map((it) => it.toString());

  Iterable<String> allExplicitGetterNames() {
    final names = explicitGetterNames().toList();
    allSupertypes()
        .forEach((it) => names.addAll(it.allExplicitGetterNames()));
    return names.toSet();
  }

  Iterable<String> explicitGetterNames() => element.accessors
      .where((it) => it.isGetter && !it.isSynthetic)
      .map((it) => it.name);

  Iterable<PropertyAccessorParser> lookUpAllExplicitGetters(
          {required LibraryElement accessibleFrom}) =>
      allExplicitGetterNames()
          .map((it) => element.lookUpGetter2(it, accessibleFrom)
              as PropertyAccessorElement?)
          .whereType<PropertyAccessorElement>()
          .map((it) => PropertyAccessorParser(it));

  Iterable<InterfaceParser> allSupertypes() => element.allSupertypes
      .where((it) => !it.isDartCoreObject)
      .map((it) => InterfaceParser(it));
}
