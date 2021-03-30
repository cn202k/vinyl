class Vinyl {
  final String toBuilderMethod;

  const Vinyl({
    this.toBuilderMethod = 'call',
  });
}

class Getter {
  const Getter._();
}

class Lazy {
  const Lazy._();
}

class Buildable {
  final Type klass;
  final String toBuilderMethod;
  final String buildMethod;

  const Buildable(
    this.klass, {
    this.toBuilderMethod = 'toBuilder',
    this.buildMethod = 'build',
  });
}

const vinyl = Vinyl();
const getter = Getter._();
const lazy = Lazy._();
