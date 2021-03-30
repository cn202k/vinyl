abstract class IDataType {
  DataType get declaration;
}

class DataSupertype implements IDataType {
  final DataType type;
  final Iterable<DataType> subtypes;

  DataSupertype({
    required this.type,
    required this.subtypes,
  });

  @override
  DataType get declaration => type;
}

class DataSubtype implements IDataType {
  final DataType type;
  final DataType supertype;

  DataSubtype({
    required this.type,
    required this.supertype,
  });

  @override
  DataType get declaration => type;
}

class DataType implements IDataType {
  final String name;
  final Iterable<TypeParameter> typeParameters;
  final Iterable<Property> properties;
  final Iterable<LazyProperty> lazyProperties;
  final DataTypeMeta meta;

  DataType({
    required this.name,
    required this.typeParameters,
    required this.properties,
    required this.lazyProperties,
    required this.meta,
  });

  @override
  DataType get declaration => this;
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

enum InterfaceType { Mixin, Class }

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

class LazyProperty {
  final String name;
  final String typeSource;

  LazyProperty({
    required this.name,
    required this.typeSource,
  });
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
