class StoreValue<T> {
  final T value;
  const StoreValue.of(this.value);
}

class ErrorAction {
  String? message;

  ErrorAction(this.message);
}
