import 'package:code_builder/code_builder.dart';
import 'package:vinyl_generator/src/model.dart';
import 'package:vinyl_generator/src/template/builder_class_template.dart';
import 'package:vinyl_generator/src/template/default_class_template.dart';

class ConcreteClassTemplate {
  final DataType model;

  ConcreteClassTemplate(this.model);

  Class inflate() {
    final klass = ClassBuilder()
      ..name = name()
      ..types.addAll(model.typeParameters.map((it) => refer('$it')))
      ..constructors.add(constructor())
      ..fields.addAll(fields())
      ..methods.addAll([
        _EqualsMethod(model).inflate(),
        _HashCodeMethod(model).inflate(),
        _ToStringMethod(model).inflate(),
      ]);
    if (model.meta.shouldGenerateBuilder)
      klass.methods.add(toBuilderMethod());
    switch (model.meta.interfaceType) {
      case InterfaceType.Class:
        klass.extend = supertype();
        break;
      case InterfaceType.Mixin:
        klass.mixins.add(supertype());
        break;
    }
    return klass.build();
  }

  Reference supertype() =>
      refer(model.typeParameters.parameterize(model.name));

  String name() => r'_$' + model.name;

  String toBuilderMethodReturnType() => model.typeParameters
      .parameterize(BuilderClassTemplate(model).name());

  Iterable<Field> fields() => model.properties.map(field);

  Field field(Property property) {
    final field = FieldBuilder()
      ..name = property.name
      ..type = refer(property.typeSource)
      ..modifier = FieldModifier.final$
      ..annotations.add(refer('override'));
    return field.build();
  }

  Method toBuilderMethod() {
    final returns = toBuilderMethodReturnType();
    final method = MethodBuilder()
      ..name = model.meta.toBuilderMethodName
      ..returns = refer(returns)
      ..annotations.add(refer('override'))
      ..lambda = true
      ..body = () {
        final args = model.properties.map((it) => it.name).join(', ');
        return Code('$returns($args)');
      }();
    return method.build();
  }

  Constructor constructor() {
    final ctor = ConstructorBuilder()
      ..optionalParameters
          .addAll(model.properties.map(constructorParameter));
    // ..initializers.addAll(model.properties
    //     .where((it) => it.hasDefaultValue)
    //     .map(fieldInitializer));
    return ctor.build();
  }

  Code fieldInitializer(Property property) {
    final field = property.name;
    final defaultClass = model.typeParameters
        .parameterize(DefaulClassTemplate(model).name());
    return Code('$field = $field ?? $defaultClass().$field');
  }

  Parameter constructorParameter(Property property) {
    final param = ParameterBuilder()
      ..name = property.name
      ..named = true
      ..toThis = true
      ..required = true;
    // if (property.hasDefaultValue) {
    //   param..type = refer(property.nullableTypeSource);
    // } else {
    //   param
    //     ..toThis = true
    //     ..required = true;
    // }
    return param.build();
  }
}

class _ToStringMethod {
  final DataType model;

  _ToStringMethod(this.model);

  Method inflate() {
    final method = MethodBuilder()
      ..name = name()
      ..returns = returnType()
      ..annotations.add(refer('override'))
      ..lambda = true
      ..body = bodyCode();
    return method.build();
  }

  String name() => 'toString';

  Reference returnType() => refer('String');

  Code bodyCode() {
    final values = model.properties
        .map((it) => '${it.name}: \$${it.name}')
        .join(', ');
    return Code("'${model.name}($values)'");
  }
}

// https://github.com/rrousselGit/freezed/blob/59f5473225c9d127abb730a69fab17fecdc89afb/packages/freezed/lib/src/templates/concrete_template.dart#L338
class _EqualsMethod {
  final DataType model;

  _EqualsMethod(this.model);

  Method inflate() {
    final method = MethodBuilder()
      ..name = name()
      ..returns = returnType()
      ..requiredParameters.add(parameter())
      ..annotations.add(refer('override'))
      ..body = bodyCode();
    return method.build();
  }

  String name() => 'operator ==';

  Reference returnType() => refer('bool');

  Parameter parameter() => Parameter(
        (param) => param
          ..name = 'other'
          ..type = refer('dynamic'),
      );

  Code bodyCode() {
    final selfType = model.typeParameters.parameterize(model.name);
    final details = [
      'other is $selfType',
      ...model.properties.map((it) {
        final name = it.name;
        return '''
    (identical(other.$name, $name) ||
                const DeepCollectionEquality().equals(other.$name, $name))
    ''';
      }),
      'super == other',
    ].join(' && ');
    return Code('return identical(this, other) || ($details);');
  }
}

// https://github.com/rrousselGit/freezed/blob/59f5473225c9d127abb730a69fab17fecdc89afb/packages/freezed/lib/src/templates/concrete_template.dart#L347
class _HashCodeMethod {
  final DataType model;

  _HashCodeMethod(this.model);

  Method inflate() {
    final method = MethodBuilder()
      ..name = name()
      ..returns = returnType()
      ..lambda = true
      ..type = MethodType.getter
      ..annotations.add(refer('override'))
      ..body = bodyCode();
    return method.build();
  }

  String name() => 'hashCode';

  Reference returnType() => refer('int');

  Code bodyCode() => Code([
        'runtimeType.hashCode',
        ...model.properties.map(
          (it) => 'const DeepCollectionEquality().hash(${it.name})',
        ),
        'super.hashCode',
      ].join('^'));
}
