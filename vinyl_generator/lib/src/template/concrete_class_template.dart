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
      ..fields.addAll([
        ...fields(),
        ...lazyFields().map((it) => it.inflateField()),
      ])
      ..methods.addAll([
        _EqualsMethod(model).inflate(),
        _HashCodeMethod(model).inflate(),
        _ToStringMethod(model).inflate(),
        ...lazyFields().map((it) => it.inflateGetter()),
      ]);
    if (model.meta.shouldGenerateBuilder) {
      klass.methods.add(toBuilderMethod());
    }
    if (model.properties.any((it) => it.hasDefaultValue)) {
      klass.constructors.addAll([
        _Constructor(model, private: true).infalte(),
        _FactoryConstructor(model).inflate(),
      ]);
    } else {
      klass.constructors.add(
        _Constructor(model, private: false).infalte(),
      );
    }
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

  Iterable<_LazyField> lazyFields() =>
      model.lazyProperties.map((it) => _LazyField(it));

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

  Code fieldInitializer(Property property) {
    final field = property.name;
    final defaultClass = model.typeParameters
        .parameterize(DefaulClassTemplate(model).name());
    return Code('$field = $field ?? $defaultClass().$field');
  }
}

class _Constructor {
  final DataType model;
  final bool private;

  _Constructor(this.model, {required this.private});

  String? name() => private ? '_' : null;

  Constructor infalte() {
    final ctor = ConstructorBuilder()
      ..name = name()
      ..optionalParameters
          .addAll(model.properties.map(constructorParameter));
    return ctor.build();
  }

  Parameter constructorParameter(Property property) {
    final param = ParameterBuilder()
      ..name = property.name
      ..named = true
      ..toThis = true
      ..required = true;
    return param.build();
  }
}

class _FactoryConstructor {
  final DataType model;

  _FactoryConstructor(this.model);

  Constructor inflate() {
    final ctor = ConstructorBuilder()
      ..factory = true
      ..optionalParameters.addAll(parameters())
      ..body = bodyCode();
    return ctor.build();
  }

  Iterable<Parameter> parameters() => model.properties.map(parameter);

  Parameter parameter(Property property) {
    final param = ParameterBuilder()
      ..name = property.name
      ..named = true;
    if (property.hasDefaultValue) {
      param..type = refer(property.nullableTypeSource);
    } else {
      param
        ..type = refer(property.typeSource)
        ..required = true;
    }
    return param.build();
  }

  Code bodyCode() {
    final concreteClass = ConcreteClassTemplate(model).name();
    final defaultClass = model.typeParameters
        .parameterize(DefaulClassTemplate(model).name());
    final def = 'default${model.name}';
    final args = model.properties
        .map((it) => it.hasDefaultValue
            ? '${it.name}: ${it.name} ?? $def.${it.name}'
            : '${it.name} : ${it.name}')
        .join(', ');
    return Code('''
    final $def = $defaultClass();
    return $concreteClass._($args);
    ''');
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

// @override
// int get sum => (_sum == vinyl ? (_sum = super.sum) : _sum) as int;

// dynamic _sum = vinyl;

class _LazyField {
  final LazyProperty model;

  _LazyField(this.model);

  Method inflateGetter() {
    final method = MethodBuilder()
      ..name = model.name
      ..returns = refer(getterReturnType())
      ..annotations.add(refer('override'))
      ..lambda = true
      ..type = MethodType.getter
      ..body = getterBodyCode();
    return method.build();
  }

  Field inflateField() {
    final field = FieldBuilder()
      ..name = fieldName()
      ..type = refer('dynamic')
      ..assignment = Code('vinyl');
    return field.build();
  }

  String fieldName() => '_${model.name}';

  String getterReturnType() => model.typeSource;

// (_sum == vinyl ? (_sum = super.sum) : _sum) as int
  Code getterBodyCode() {
    final retType = getterReturnType();
    final field = fieldName();
    final supField = 'super.${model.name}';
    return Code(
      '($field == vinyl ? ($field = $supField) : $field) as $retType',
    );
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
