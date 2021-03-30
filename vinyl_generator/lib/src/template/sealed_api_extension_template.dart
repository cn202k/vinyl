import 'package:code_builder/code_builder.dart';
import 'package:vinyl_generator/src/model.dart';

class SealedApiExtensionTemplate {
  final DataSupertype model;

  SealedApiExtensionTemplate(this.model);

  Extension inflate() {
    final ext = ExtensionBuilder()
      ..name = name()
      ..types.addAll(typeParameters())
      ..on = refer(targetType())
      ..methods.addAll(methods());
    return ext.build();
  }

  String name() => '\$Sealed${model.declaration.name}Api';

  String targetType() => model.declaration.typeParameters
      .parameterize(model.declaration.name);

  Iterable<Reference> typeParameters() =>
      model.declaration.typeParameters.map((it) => refer(it.source()));

  Iterable<Method> methods() => [
        _MapMethod(model).inflate(),
        _MatchMethod(model).inflate(),
        ...model.subtypes.map((it) => _IsMethod(it).infalte()),
        ...model.subtypes.map((it) => _AsMethod(it).infalte()),
      ];
}

/*

  R map<R>(
    R data(Data<T> data),
    R error(Error<T> error),
  ) {
    final self = this;
    if (self is Data<T>) return data(self);
    if (self is Error<T>) return error(self);
    throw StateError("Unexpected type : ${self.runtimeType}");
  }
*/

class _MapMethod {
  final DataSupertype model;

  _MapMethod(this.model);

  Method inflate() {
    final method = MethodBuilder()
      ..name = 'map'
      ..returns = refer(returnType())
      ..types.add(refer(returnType()))
      ..requiredParameters.addAll(parameters())
      ..body = bodyCode();
    return method.build();
  }

  String returnType() => 'R';

  Iterable<Parameter> parameters() => model.subtypes.map(parameter);

  Parameter parameter(DataType subtype) {
    final param = ParameterBuilder()
      ..name = parameterName(subtype)
      ..type = refer(parameterType(subtype));
    return param.build();
  }

  String parameterName(DataType subtype) {
    final base = subtype.name;
    if (base.length < 2) return base.toLowerCase();
    return base[0].toLowerCase() + base.substring(1);
  }

  String targetSubtype(DataType subtype) =>
      model.declaration.typeParameters.parameterize(subtype.name);

  String parameterType(DataType subtype) =>
      '${returnType()} Function(${targetSubtype(subtype)} value)';

  Code bodyCode() {
    return Code([
      'final self = this;',
      for (final sub in model.subtypes)
        'if (self is ${targetSubtype(sub)}) return ${parameterName(sub)}(self);',
      'throw StateError("Unexpected type : \${self.runtimeType}");',
    ].join('\n'));
  }
}

/*

  R? match<R>({
    R data(Data<T> data)?,
    R error(Error<T> error)?,
    R otherwise(Result<T> result)?,
  }) {
    final self = this;
    if (self is Data<T>) {
      if (data != null) return data(self);
    } else if (self is Error<T>) {
      if (error != null) return error(self);
    }
    return otherwise?.call(self);
  }
*/

class _MatchMethod {
  final DataSupertype model;

  _MatchMethod(this.model);

  Method inflate() {
    final method = MethodBuilder()
      ..name = 'match'
      ..returns = refer(returnType())
      ..types.add(refer(typeParameter()))
      ..optionalParameters.addAll(parameters())
      ..body = bodyCode();
    return method.build();
  }

  String typeParameter() => 'R';

  String returnType() => typeParameter() + '?';

  Iterable<Parameter> parameters() => [
        ...model.subtypes.map(parameter),
        parameterOtherwise(),
      ];

  Parameter parameter(DataType subtype) {
    final param = ParameterBuilder()
      ..name = parameterName(subtype)
      ..type = refer(parameterType(subtype))
      ..named = true;
    return param.build();
  }

  Parameter parameterOtherwise() {
    final param = ParameterBuilder()
      ..name = 'otherwise'
      ..type = refer(parameterType(model.declaration))
      ..named = true;
    return param.build();
  }

  String parameterName(DataType subtype) {
    final base = subtype.name;
    if (base.length < 2) return base.toLowerCase();
    return base[0].toLowerCase() + base.substring(1);
  }

  String targetSubtype(DataType subtype) =>
      model.declaration.typeParameters.parameterize(subtype.name);

  String parameterType(DataType subtype) =>
      '${returnType()} Function(${targetSubtype(subtype)} value)?';

  Code bodyCode() {
    return Code([
      'final self = this;',
      model.subtypes.map((it) => '''
        if (self is ${targetSubtype(it)}) {
          if (${parameterName(it)} != null) return ${parameterName(it)}(self);
        }
        ''').join(' else '),
      'return otherwise?.call(self);',
    ].join('\n'));
  }
}

class _IsMethod {
  final DataType subtype;

  _IsMethod(this.subtype);

  Method infalte() {
    final method = MethodBuilder()
      ..name = 'is${subtype.name}'
      ..returns = refer('bool')
      ..type = MethodType.getter
      ..lambda = true
      ..body = Code('this is ${targetType()}');
    return method.build();
  }

  String targetType() => subtype.typeParameters.parameterize(subtype.name);
}

class _AsMethod {
  final DataType subtype;

  _AsMethod(this.subtype);

  Method infalte() {
    final method = MethodBuilder()
      ..name = 'as${subtype.name}'
      ..returns = refer(returnType())
      ..type = MethodType.getter
      ..body = Code('''
      final self = this;
      return self is ${targetType()} ? self : null;
      ''');
    return method.build();
  }

  String returnType() => targetType() + '?';

  String targetType() => subtype.typeParameters.parameterize(subtype.name);
}
