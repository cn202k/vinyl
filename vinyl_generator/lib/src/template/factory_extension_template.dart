import 'package:code_builder/code_builder.dart';
import 'package:vinyl_generator/src/model.dart';
import 'package:vinyl_generator/src/template/concrete_class_template.dart';
import 'package:vinyl_generator/src/template/default_class_template.dart';

class FactoryExtensionTemplate {
  final DataType model;

  FactoryExtensionTemplate(this.model);

  Extension inflate() {
    final ext = ExtensionBuilder()
      ..name = name()
      ..on = refer('Vinyl')
      ..methods.add(FactoryMethod(model).inflate());
    return ext.build();
  }

  String name() => '${model.name}Factory';
}

class FactoryMethod {
  final DataType model;

  FactoryMethod(this.model);

  String name() {
    final base = model.name;
    if (base.length < 2) return base;
    return base[0].toLowerCase() + base.substring(1);
  }

  Reference returnType() =>
      refer(model.typeParameters.parameterize(model.name));

  Iterable<Reference> typeParameters() =>
      model.typeParameters.map((it) => refer(it.source()));

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
    return $concreteClass($args);
    ''');
  }

  Method inflate() {
    final method = MethodBuilder()
      ..name = name()
      ..returns = returnType()
      ..types.addAll(typeParameters())
      ..optionalParameters.addAll(parameters())
      ..body = bodyCode();
    return method.build();
  }
}

/*

extension UserFactory on Vinyl {
  User user<T extends Foo>({
    required String name,
    required String mail,
    required T foo,
    required List<String>? favs,
  }) =>
      _$User(
        name: name,
        mail: mail,
        foo: foo,
        favs: favs,
      );
}

*/
