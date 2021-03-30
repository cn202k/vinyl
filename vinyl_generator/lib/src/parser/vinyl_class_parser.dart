import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';
import 'package:vinyl/vinyl.dart';
import 'package:vinyl_generator/src/parser/class_parser.dart';
import 'package:vinyl_generator/src/parser/property_accessor_parser.dart';

class VinylClassParser extends ClassParser {
  static VinylClassParser? from(ClassElement element) {
    final DartObject? annotation =
        TypeChecker.fromRuntime(Vinyl).firstAnnotationOf(element);
    if (annotation == null) return null;
    return VinylClassParser._(
      element,
      Vinyl(
        toBuilderMethod:
            annotation.getField('toBuilderMethod').toStringValue(),
      ),
    );
  }

  final Vinyl annotation;

  VinylClassParser._(
    ClassElement element,
    this.annotation,
  ) : super(element);

  Iterable<VinylGetterParser> allExplicitGetters() =>
      lookUpAllExplicitGetters(accessibleFrom: element.library)
          .map((it) => VinylGetterParser._(it.element));

  Iterable<VinylClassParser>
      directVinylSubclassesDeclaredInSameLibrary() =>
          directSubtypesDeclaredInSameLibrary()
              .map((it) => VinylClassParser.from(it.element))
              .whereType<VinylClassParser>();

  Iterable<VinylClassParser>
      directVinylSuperclassesDeclaredInSameLibrary() =>
          directSupertypesDeclaredInSameLibrary()
              .map((it) => VinylClassParser.from(it.element))
              .whereType<VinylClassParser>();
}

class VinylGetterParser extends PropertyAccessorParser {
  VinylGetterParser._(PropertyAccessorElement getter) : super(getter);

  BuilderAnnotationParser? builderAnnotation() {
    final DartObject? annotation = const TypeChecker.fromRuntime(Buildable)
        .firstAnnotationOf(element);
    if (annotation == null) return null;
    return BuilderAnnotationParser._(annotation);
  }

  bool hasLazyAnnotation() =>
      const TypeChecker.fromRuntime(Lazy).hasAnnotationOf(element);

  bool hasGetterAnnotation() =>
      const TypeChecker.fromRuntime(Getter).hasAnnotationOf(element);

  bool hasBuilderAnnotation() =>
      const TypeChecker.fromRuntime(Buildable).hasAnnotationOf(element);
}

class BuilderAnnotationParser {
  final DartObject annotation;

  BuilderAnnotationParser._(this.annotation);

  DartType klass() => annotation.getField('klass').toTypeValue();

  String toBuilderMethod() =>
      annotation.getField('toBuilderMethod').toStringValue();

  String buildMethod() =>
      annotation.getField('buildMethod').toStringValue();
}
