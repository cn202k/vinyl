import 'package:code_builder/code_builder.dart';
import 'package:vinyl_generator/src/model.dart';
import 'package:vinyl_generator/src/template/concrete_class_template.dart';

class BuilderClassTemplate {
  final DataType model;

  BuilderClassTemplate(this.model);

  Class inflate() {
    final klass = ClassBuilder()
      ..name = name()
      ..implements.add(interface())
      ..types.addAll(typeParameters())
      // ..constructors.add(constructor())
      ..constructors.add(_Constructor(model).inflate())
      ..fields.addAll(fields())
      ..methods.addAll([
        _SourceMethod(model).inflate(),
        _BuildMethod(model).inflate(),
      ]);
    return klass.build();
  }

  String targetType() => model.typeParameters.parameterize(model.name);

  Reference interface() => refer('DataBuilder<${targetType()}>');

  Iterable<Reference> typeParameters() =>
      model.typeParameters.map((it) => refer('$it'));

  String name() => '${model.name}Builder';

  Iterable<Field> fields() => model.properties.map(field);

  Reference fieldType(Property property) {
    final builder = property.builder;
    if (builder == null) return refer(property.typeSource);
    final type = property.typeArguments.parameterize(builder.name);
    return property.isNullable ? refer('$type?') : refer(type);
  }

  Field field(Property property) {
    final field = FieldBuilder()
      ..name = property.name
      ..type = fieldType(property);
    return field.build();
  }

  Constructor constructor() {
    final ctor = ConstructorBuilder()
      ..requiredParameters.addAll(
        model.properties.map(
          (prop) => Parameter(
            (param) => param
              ..name = prop.name
              ..toThis = true,
          ),
        ),
      );
    return ctor.build();
  }
}

class _BuildMethod {
  final DataType model;

  _BuildMethod(this.model);

  Reference returnType() =>
      refer(model.typeParameters.parameterize(model.name));

  Method inflate() {
    final method = MethodBuilder()
      ..name = 'build'
      ..returns = returnType()
      ..annotations.add(refer('override'))
      ..lambda = true
      ..body = bodyCode();
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
  final DataType model;

  _SourceMethod(this.model);

  Method inflate() {
    final method = MethodBuilder()
      ..name = name()
      ..type = MethodType.setter
      ..requiredParameters.add(parameter())
      ..body = bodyCode();
    return method.build();
  }

  String name() => 'source';

  Code bodyCode() => Code(model.properties.map(assignmentCode).join('\n'));

  Reference parameterType() =>
      refer(model.typeParameters.parameterize(model.name));

  Parameter parameter() => Parameter(
        (param) => param
          ..name = 'value'
          ..type = parameterType(),
      );

  String assignmentCode(Property property) {
    final prop = property.name;
    final builder = property.builder;
    if (builder == null) return '$prop = value.$prop;';
    final toBuilder = builder.toBuilderMethodName;
    return property.isNullable
        ? '$prop = value.$prop?.$toBuilder();'
        : '$prop = value.$prop.$toBuilder();';
  }
}
