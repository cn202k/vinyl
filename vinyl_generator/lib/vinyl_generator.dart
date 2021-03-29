library vinyl_generator;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:vinyl_generator/src/generator.dart';

Builder vinyl_generator(BuilderOptions options) =>
    PartBuilder([VinylGenerator()], '.vinyl.dart');
