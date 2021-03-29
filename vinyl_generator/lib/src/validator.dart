import 'package:source_gen/source_gen.dart';
import 'package:vinyl_generator/src/parser/vinyl_class_parser.dart';

VinylClassParser validate(VinylClassParser klass) {
  _unnamedDefaultConstructorIsNeeded(klass);
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
