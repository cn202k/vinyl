class DataType {
  final String name;
  final Iterable<TypeParameter> typeParameters;
  final Iterable<Property> properties;
  final DataTypeMeta meta;

  DataType({
    required this.name,
    required this.typeParameters,
    required this.properties,
    required this.meta,
  });
}

class DataTypeMeta {
  final InterfaceType interfaceType;
  final bool shouldGenerateBuilder;
  final String toBuilderMethodName;

  DataTypeMeta({
    required this.interfaceType,
    required this.shouldGenerateBuilder,
    required this.toBuilderMethodName,
  });
}

enum InterfaceType {
  Mixin,
  Class,
}

class TypeParameter {
  final String name;
  final String? bound;

  TypeParameter({
    required this.name,
    required this.bound,
  });

  @override
  String toString() => bound != null ? '$name extends $bound' : name;

  String source() => toString();
}

extension TypeParameters on Iterable<TypeParameter> {
  String parameterize(String baseName) {
    if (this.isEmpty) return baseName;
    final params = this.map((it) => it.name).join(', ');
    return '$baseName<$params>';
  }

  Iterable<String> withoutBound() => this.map((it) => it.name);
}

class TypeArgument {
  final String name;

  TypeArgument(this.name);
}

extension TypeArguments on Iterable<TypeArgument> {
  String parameterize(String baseName) {
    if (this.isEmpty) return baseName;
    final params = this.map((it) => it.name).join(', ');
    return '$baseName<$params>';
  }
}

class Property {
  final String name;
  final String type;
  final Iterable<TypeArgument> typeArguments;
  final bool isNullable;
  final bool hasDefaultValue;
  final PropertyBuilder? builder;

  Property({
    required this.name,
    required this.type,
    required this.typeArguments,
    required this.isNullable,
    required this.hasDefaultValue,
    required this.builder,
  });

  String get typeSource => isNullable
      ? typeArguments.parameterize(type) + '?'
      : typeArguments.parameterize(type);

  String get nullableTypeSource =>
      isNullable ? typeSource : '$typeSource?';
}

class PropertyBuilder {
  final String name;
  final String toBuilderMethodName;
  final String buildMethodName;

  PropertyBuilder({
    required this.name,
    required this.toBuilderMethodName,
    required this.buildMethodName,
  });
}
