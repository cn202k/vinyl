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

  bool hasUnnamedDefaultConstructor() {
    final ConstructorElement? ctor = element.unnamedConstructor;
    return ctor != null && ctor.parameters.isEmpty;
  }

  Iterable<PropertyAccessorParser> explicitGetters() => element.accessors
      .where((it) => it.isGetter && !it.isSynthetic)
      .map((it) => PropertyAccessorParser(it));

  Iterable<PropertyAccessorParser> lookUpAllExplicitGetters(
      {required LibraryElement accessibleFrom}) {
    final getters = <String, PropertyAccessorParser>{};
    for (final supertype in supertypes()) {
      supertype
          .lookUpAllExplicitGetters(accessibleFrom: accessibleFrom)
          .forEach((getter) => getters[getter.name()] = getter);
    }
    for (final getter in explicitGetters()) {
      getters[getter.name()] = getter;
    }
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
      element.methods.where((it) => it.name == name).isNotEmpty;

  DartObject? firstAnnotationOf(TypeChecker typeChecker) =>
      typeChecker.firstAnnotationOf(element);

  bool isMixin() => element.isMixin;

  Iterable<ClassParser> directSubtypesDeclaredInSameLibrary() =>
      element.library.topLevelElements
          .whereType<ClassElement>()
          .where((klass) => klass.allSupertypes
              .where((sup) => sup.element.id == element.id)
              .isNotEmpty)
          .map((klass) => ClassParser(klass));

  Iterable<ClassParser> directSupertypesDeclaredInSameLibrary() =>
      element.allSupertypes
          .where((it) => it.element.library.id == element.library.id)
          .map((it) => ClassParser(it.element));
}
