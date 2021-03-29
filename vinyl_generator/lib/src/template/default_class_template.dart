import 'package:code_builder/code_builder.dart';
import 'package:vinyl_generator/src/model.dart';
import 'package:vinyl_generator/src/template/concrete_class_template.dart';

class DefaulClassTemplate {
  final DataType model;

  DefaulClassTemplate(this.model);

  Class inflate() {
    final klass = ClassBuilder()
      ..name = name()
      ..types.addAll(model.typeParameters.map((it) => refer('$it')))
      ..methods.addAll(getters());
    if (model.meta.shouldGenerateBuilder)
      klass.methods.add(toBuilderMethod());
    switch (model.meta.interfaceType) {
      case InterfaceType.Class:
        klass.extend = ConcreteClassTemplate(model).supertype();
        break;
      case InterfaceType.Mixin:
        klass.mixins.add(ConcreteClassTemplate(model).supertype());
        break;
    }
    return klass.build();
  }

  String name() => r'_$Default' + model.name;

  Iterable<Method> getters() => model.properties.map(getter);

  Method getter(Property property) {
    final field = MethodBuilder()
      ..name = property.name
      ..returns = property.hasDefaultValue
          ? refer(property.typeSource)
          : refer('Never')
      ..type = MethodType.getter
      ..lambda = true
      ..annotations.add(refer('override'))
      ..body = property.hasDefaultValue
          ? Code('super.${property.name}')
          : Code('throw UnimplementedError()');
    return field.build();
  }

  Method toBuilderMethod() {
    final method = MethodBuilder()
      ..name = model.meta.toBuilderMethodName
      ..returns = refer('Never')
      ..annotations.add(refer('override'))
      ..lambda = true
      ..body = Code('throw UnimplementedError()');
    return method.build();
  }
}
