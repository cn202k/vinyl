import 'package:source_gen/source_gen.dart';
import 'package:vinyl/vinyl.dart';
import 'package:vinyl_generator/src/model.dart';
import 'package:vinyl_generator/src/parser/property_accessor_parser.dart';
import 'package:vinyl_generator/src/parser/vinyl_class_parser.dart';

DataType transform(VinylClassParser klass) => DataType(
      name: klass.name(),
      typeParameters: klass.typeParameters().map(
            (it) => TypeParameter(
              name: it.key,
              bound: it.value,
            ),
          ),
      properties: _properties(klass),
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

Iterable<Property> _properties(VinylClassParser klass) => klass
    .allUserDefinedGetters()
    .where((it) => !it.hasAnnotationOf(
          const TypeChecker.fromRuntime(Getter),
        ))
    .map(_property);

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
  final vinylClass = transform(parser);
  if (!vinylClass.meta.shouldGenerateBuilder) return null;
  return PropertyBuilder(
    name: vinylClass.name + 'Builder',
    toBuilderMethodName: vinylClass.meta.toBuilderMethodName,
    buildMethodName: 'build',
  );
}
