import 'package:code_builder/code_builder.dart';
import 'package:vinyl_generator/src/model.dart';
import 'package:vinyl_generator/src/template/concrete_class_template.dart';

class BuilderClassTemplate {
  final IDataType iModel;
  final DataType model;

  factory BuilderClassTemplate(IDataType model) {
    if (model is DataType) return BuilderClassTemplate._(model, model);
    if (model is DataSupertype)
      return BuilderClassTemplate._(model, model.type);
    if (model is DataSubtype)
      return BuilderClassTemplate._(model, model.type);
    throw Exception();
  }

  BuilderClassTemplate._(this.iModel, this.model);

  Class inflate() {
    final klass = ClassBuilder()
      ..name = name()
      ..implements.add(interface())
      ..types.addAll(typeParameters())
      ..fields.addAll(fields())
      ..methods.addAll([
        _SourceMethod(iModel, model).inflate(),
        _BuildMethod(iModel, model).inflate(),
      ]);

    if (iModel is DataSupertype) {
      klass.abstract = true;
    } else {
      klass.constructors.add(_Constructor(model).inflate());
    }
    return klass.build();
  }

  String targetType() => model.typeParameters.parameterize(model.name);

  // Reference interface() => refer('Builder<${targetType()}>');
  Reference interface() {
    final model = this.iModel;
    if (model is DataType) return refer('Builder<${targetType()}>');
    if (model is DataSupertype) return refer(r'Builder<$T>');
    if (model is DataSubtype) {
      final typeArgs = [
        ...typeParameters().map((it) => it.symbol),
        targetType(),
      ].join(', ');
      final supBuilder = BuilderClassTemplate(model.supertype).name();
      return refer('$supBuilder<$typeArgs>');
    }
    throw Exception();
  }

  // Iterable<Reference> typeParameters() =>
  //     model.typeParameters.map((it) => refer('$it'));

  Iterable<Reference> typeParameters() {
    final params = model.typeParameters.map((it) => refer('$it')).toList();
    if (iModel is DataSupertype) {
      params.add(refer('\$T extends ${targetType()}'));
    }
    return params;
  }

  String name() => '${model.name}Builder';

  Iterable<Field> fields() => model.properties.map(field);

  Reference fieldType(Property property) {
    final builder = property.builder;
    late String type;
    if (builder == null) {
      type = property.typeSource;
    } else {
      type = property.typeArguments.parameterize(builder.name);
      type = property.isNullable ? '$type?' : type;
    }
    if (iModel is DataSupertype) type = 'abstract $type';
    return refer(type);
  }

  Field field(Property property) {
    final field = FieldBuilder()
      ..name = property.name
      ..type = fieldType(property);
    if (iModel is DataSubtype) {
      field.annotations.add(refer('override'));
    }
    return field.build();
  }
}

class _BuildMethod {
  final IDataType iModel;
  final DataType model;

  _BuildMethod(this.iModel, this.model);

  // Reference returnType() =>
  //     refer(model.typeParameters.parameterize(model.name));

  Reference returnType() {
    if (iModel is DataSupertype) return refer(r'$T');
    return refer(model.typeParameters.parameterize(model.name));
  }

  Method inflate() {
    final method = MethodBuilder()
      ..name = 'build'
      ..returns = returnType()
      ..annotations.add(refer('override'));
    if (iModel is! DataSupertype) {
      method
        ..lambda = true
        ..body = bodyCode();
    }
    return method.build();
  }

  Code bodyCode() {
    final concreteClass = model.typeParameters
        .parameterize(ConcreteClassTemplate(model).name());
    final args = constructorArguments();
    return Code('$concreteClass($args)');
  }

  String constructorArguments() =>
      model.properties.map(constructorArgument).join(', ');

  String constructorArgument(Property property) {
    final prop = property.name;
    final builder = property.builder;
    if (builder == null) return '$prop: $prop';
    final build = builder.buildMethodName;
    return property.isNullable
        ? '$prop: $prop?.$build()'
        : '$prop: $prop.$build()';
  }
}

class _Constructor {
  final DataType model;

  _Constructor(this.model);

  Constructor inflate() {
    final ctor = ConstructorBuilder()
      ..requiredParameters.addAll(parameters())
      ..initializers.addAll(initializers());
    return ctor.build();
  }

  Iterable<Parameter> parameters() => model.properties.map(parameter);

  Parameter parameter(Property property) {
    final param = ParameterBuilder();
    param.name = property.name;
    if (property.builder != null)
      param.type = refer(property.typeSource);
    else
      param.toThis = true;
    return param.build();
  }

  Iterable<Code> initializers() =>
      model.properties.map(builderInitializationCode).whereType<Code>();

  Code? builderInitializationCode(Property property) {
    final builder = property.builder;
    if (builder == null) return null;
    final prop = property.name;
    final toBuilder = builder.toBuilderMethodName;
    return property.isNullable
        ? Code('$prop = $prop?.$toBuilder()')
        : Code('$prop = $prop.$toBuilder()');
  }
}

class _SourceMethod {
  final IDataType iModel;
  final DataType model;

  _SourceMethod(this.iModel, this.model);

  Method inflate() {
    final method = MethodBuilder()
      ..name = name()
      ..type = MethodType.setter
      ..requiredParameters.add(parameter());
    if (iModel is! DataSupertype) {
      method.body = bodyCode();
    }
    return method.build();
  }

  String name() => 'source';

  Code bodyCode() => Code(model.properties.map(assignmentCode).join('\n'));

  Reference parameterType() =>
      refer(model.typeParameters.parameterize(model.name));

  String parameterName() => r'value$';

  Parameter parameter() => Parameter(
        (param) => param
          ..name = parameterName()
          ..type = parameterType()
          ..covariant = iModel is DataSupertype,
      );

  String assignmentCode(Property property) {
    final param = parameterName();
    final prop = property.name;
    final builder = property.builder;
    if (builder == null) return '$prop = $param.$prop;';
    final toBuilder = builder.toBuilderMethodName;
    return property.isNullable
        ? '$prop = $param.$prop?.$toBuilder();'
        : '$prop = $param.$prop.$toBuilder();';
  }
}
