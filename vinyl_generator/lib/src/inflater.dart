import 'package:code_builder/code_builder.dart';
import 'package:vinyl_generator/src/model.dart';
import 'package:vinyl_generator/src/template/builder_class_template.dart';
import 'package:vinyl_generator/src/template/concrete_class_template.dart';
import 'package:vinyl_generator/src/template/default_class_template.dart';
import 'package:vinyl_generator/src/template/factory_method_template.dart';

final _emitter = DartEmitter();

// String inflate(DataType model) => <Spec>[
//       ConcreteClassTemplate(model).inflate(),
//       FactoryMethodTemplate(model).inflate(),
//       if (model.properties.any((it) => it.hasDefaultValue))
//         DefaulClassTemplate(model).inflate(),
//       if (model.meta.shouldGenerateBuilder)
//         BuilderClassTemplate(model).inflate(),
//     ].map((it) => it.accept(_emitter).toString()).join('\n\n');

String inflate(IDataType model) => <Spec>[
      if (model is! DataSupertype) ...[
        ConcreteClassTemplate(model).inflate(),
        FactoryMethodTemplate(model).inflate(),
        if (model.declaration.properties.any((it) => it.hasDefaultValue))
          DefaulClassTemplate(model).inflate(),
      ],
      if (model.declaration.meta.shouldGenerateBuilder)
        BuilderClassTemplate(model).inflate(),
    ].map((it) => it.accept(_emitter).toString()).join('\n\n');
