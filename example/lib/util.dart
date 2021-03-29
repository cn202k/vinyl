extension Chainable<T> on T {
  T mapIf(bool cond, {required T then(T self)}) =>
      cond ? then(this) : this;
}
