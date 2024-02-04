import 'dart:async';

Function debounce(
    {required Function(String) callback,
    Duration duration = const Duration(milliseconds: 500)}) {
  Timer? debounce;

  return (String value) {
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(duration, () => callback(value));
  };
}
