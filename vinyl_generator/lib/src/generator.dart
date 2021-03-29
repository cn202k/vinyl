import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:vinyl/vinyl.dart';
import 'package:vinyl_generator/src/inflater.dart';
import 'package:vinyl_generator/src/parser/vinyl_class_parser.dart';
import 'package:vinyl_generator/src/transformer.dart';

class VinylGenerator extends GeneratorForAnnotation<Vinyl> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        "@vinyl can be used only for classes or mixins",
        element: element,
      );
    }
    return inflate(transform(VinylClassParser.from(element)!));
  }
}
