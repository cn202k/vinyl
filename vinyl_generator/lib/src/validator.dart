import 'package:source_gen/source_gen.dart';
import 'package:vinyl_generator/src/parser/vinyl_class_parser.dart';

VinylClassParser validate(VinylClassParser klass) {
  _unnamedDefaultConstructorIsNeeded(klass);
  _sealedClassConstraint1(klass);
  _sealedClassConstraint2(klass);
  _sealedClassConstraint3(klass);
  klass.allExplicitGetters().forEach((getter) {
    _cannotUseGetterAndLazyAtSameTime(getter);
    _getterMustHasConcreteBody(getter);
    _lazyPropertyMustHasConcreteBody(getter);
    _aboutBuilderAnnotation(getter);
  });
  return klass;
}

void _unnamedDefaultConstructorIsNeeded(VinylClassParser klass) {
  if (!klass.hasUnnamedDefaultConstructor()) {
    throw InvalidGenerationSourceError(
      "@vinyl class must has an unnamed default constructor",
      element: klass.element,
    );
  }
}

void _sealedClassConstraint1(VinylClassParser klass) {
  if (klass.directVinylSuperclassesDeclaredInSameLibrary().isNotEmpty &&
      klass.directVinylSubclassesDeclaredInSameLibrary().isNotEmpty) {
    throw InvalidGenerationSourceError(
      "The @vinyl class cannot be a super class of another @vinyl class because it inherits another @vinyl class",
      element: klass.element,
    );
  }
}

void _sealedClassConstraint2(VinylClassParser klass) {
  if (klass.directVinylSuperclassesDeclaredInSameLibrary().length > 1) {
    throw InvalidGenerationSourceError(
      "A @vinyl class cannot inherits two or more @vinyl classes",
      element: klass.element,
    );
  }
}

void _sealedClassConstraint3(VinylClassParser klass) {
  final annotations = [
    klass.annotation,
    ...klass
        .directVinylSubclassesDeclaredInSameLibrary()
        .map((it) => it.annotation),
  ];
  if (annotations.map((it) => it.toBuilderMethod).toSet().length > 1) {
    throw InvalidGenerationSourceError(
      "Sealed @vinyl classes must share the name of toBuilder method in configuration",
      element: klass.element,
    );
  }
}

void _cannotUseGetterAndLazyAtSameTime(VinylGetterParser getter) {
  if (getter.hasLazyAnnotation() && getter.hasGetterAnnotation()) {
    throw InvalidGenerationSourceError(
      "Cannot use @getter and @lazy annotations at the same time",
      element: getter.element,
    );
  }
}

void _getterMustHasConcreteBody(VinylGetterParser getter) {
  if (getter.hasGetterAnnotation() && getter.isAbstract()) {
    throw InvalidGenerationSourceError(
      "Cannot use @getter for abstract getter",
      element: getter.element,
    );
  }
}

void _lazyPropertyMustHasConcreteBody(VinylGetterParser getter) {
  if (getter.hasLazyAnnotation() && getter.isAbstract()) {
    throw InvalidGenerationSourceError(
      "Cannot use @lazy for abstract getter",
      element: getter.element,
    );
  }
}

void _aboutBuilderAnnotation(VinylGetterParser getter) {
  if (getter.hasBuilderAnnotation() &&
      (getter.hasLazyAnnotation() || getter.hasGetterAnnotation())) {
    throw InvalidGenerationSourceError(
      "Cannot use @Builder with @lazy or @getter",
      element: getter.element,
    );
  }
}
