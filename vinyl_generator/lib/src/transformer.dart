import 'package:vinyl_generator/src/model.dart';
import 'package:vinyl_generator/src/parser/vinyl_class_parser.dart';

IDataType transform(VinylClassParser klass) {
  final sups = klass.directVinylSuperclassesDeclaredInSameLibrary();
  if (sups.isNotEmpty) {
    return DataSubtype(
      type: _dataType(klass),
      supertype: _dataType(sups.first),
    );
  }
  final subs = klass.directVinylSubclassesDeclaredInSameLibrary();
  if (subs.isNotEmpty) {
    return DataSupertype(
      type: _dataType(klass),
      subtypes: subs.map(_dataType),
    );
  }
  return _dataType(klass);
}

DataType _dataType(VinylClassParser klass) => DataType(
      name: klass.name(),
      typeParameters: klass.typeParameters().map(
            (it) => TypeParameter(
              name: it.key,
              bound: it.value,
            ),
          ),
      properties: _properties(klass),
      lazyProperties: _lazyProperties(klass),
      meta: _meta(klass),
    );

DataTypeMeta _meta(VinylClassParser klass) => DataTypeMeta(
      interfaceType:
          klass.isMixin() ? InterfaceType.Mixin : InterfaceType.Class,
      shouldGenerateBuilder: _shouldGenerateBuilder(klass),
      toBuilderMethodName: klass.annotation.toBuilderMethod,
    );

bool _shouldGenerateBuilder(VinylClassParser klass) =>
    klass.hasMethod(klass.annotation.toBuilderMethod);

Iterable<Property> _properties(VinylClassParser klass) =>
    klass.allExplicitGetters().where(_isProperty).map(_property);

Iterable<LazyProperty> _lazyProperties(VinylClassParser klass) =>
    klass.allExplicitGetters().where(_isLazyProperty).map(_lazyProperty);

bool _isProperty(VinylGetterParser getter) =>
    !getter.hasGetterAnnotation() && !getter.hasLazyAnnotation();

bool _isLazyProperty(VinylGetterParser getter) =>
    getter.hasLazyAnnotation();

Property _property(VinylGetterParser getter) => Property(
      name: getter.name(),
      type: getter.returnType().name(),
      typeArguments: getter
          .returnType()
          .typeArguments()
          .map((it) => TypeArgument(it)),
      isNullable: getter.returnType().isNullable(),
      hasDefaultValue: !getter.isAbstract(),
      builder: _propertyBuilder(getter),
    );

LazyProperty _lazyProperty(VinylGetterParser getter) => LazyProperty(
      name: getter.name(),
      typeSource: getter.returnType().source(),
    );

PropertyBuilder? _propertyBuilder(VinylGetterParser getter) {
  final builder = getter.builderAnnotation();
  if (builder != null)
    return PropertyBuilder(
      name: builder.klass().element.name,
      toBuilderMethodName: builder.toBuilderMethod(),
      buildMethodName: builder.buildMethod(),
    );
  final klass = getter.returnType().definition()?.element;
  if (klass == null) return null;
  final parser = VinylClassParser.from(klass);
  if (parser == null) return null;
  final vinylClass = transform(parser).declaration;
  if (!vinylClass.meta.shouldGenerateBuilder) return null;
  return PropertyBuilder(
    name: vinylClass.name + 'Builder',
    toBuilderMethodName: vinylClass.meta.toBuilderMethodName,
    buildMethodName: 'build',
  );
}
