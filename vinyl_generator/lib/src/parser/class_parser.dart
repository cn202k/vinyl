import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';
import 'package:vinyl_generator/src/parser/interface_parser.dart';
import 'package:vinyl_generator/src/parser/property_accessor_parser.dart';

class ClassParser {
  final ClassElement element;

  ClassParser(this.element);

  String name() => element.name;

  Iterable<MapEntry<String, String?>> typeParameters() =>
      element.typeParameters.map(
        (it) {
          final type = it.name;
          final DartType? bound = it.bound;
          return MapEntry(type, bound?.toString());
        },
      );

  Iterable<PropertyAccessorParser> userDefinedGetters() => element.fields
      .map((it) => it.getter as PropertyAccessorElement?)
      .whereType<PropertyAccessorElement>()
      .where((it) => !it.isSynthetic)
      .map((it) => PropertyAccessorParser(it));

  Iterable<PropertyAccessorParser> allUserDefinedGetters() {
    final getters = <String, PropertyAccessorParser>{};
    supertypes().forEach((sup) {
      sup.definition().allUserDefinedGetters().forEach((getter) {
        getters[getter.name()] = getter;
      });
    });
    userDefinedGetters().forEach((getter) {
      getters[getter.name()] = getter;
    });
    return getters.values;
  }

  Iterable<InterfaceParser> supertypes() => element.allSupertypes
      .where((it) => !it.isDartCoreObject)
      .map((it) => InterfaceParser(it));

  InterfaceParser? superClass() {
    final InterfaceType? sup = element.supertype;
    if (sup == null) return null;
    return InterfaceParser(sup);
  }

  bool hasMethod(String name) =>
      element.lookUpMethod(name, element.library) != null;

  DartObject? firstAnnotationOf(TypeChecker typeChecker) =>
      typeChecker.firstAnnotationOf(element);

  bool isMixin() => element.isMixin;
}
