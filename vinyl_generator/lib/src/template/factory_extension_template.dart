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

  String name() => 'new${model.name}';

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

  String constructorArgumentCode(Property property) =>
      '${property.name}: ${property.name}';

  String constructorArgumentsCode() =>
      model.properties.map(constructorArgumentCode).join(', ');

  Code bodyCode() {
    final concreteClass = ConcreteClassTemplate(model).name();
    final args = constructorArgumentsCode();
    return Code('$concreteClass($args);');
  }

  Method inflate() {
    final method = MethodBuilder()
      ..name = name()
      ..returns = returnType()
      ..types.addAll(typeParameters())
      ..optionalParameters.addAll(parameters())
      ..lambda = true
      ..body = bodyCode();
    return method.build();
  }
}
