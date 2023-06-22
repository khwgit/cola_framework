void debug(void Function() function) {
  assert(() {
    function();
    return true;
  }());
}
