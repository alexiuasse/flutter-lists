String getWithoutSpaces(String s) {
  String tmp = s.substring(1, s.length - 1);
  while (tmp.startsWith(' ')) {
    tmp = tmp.substring(1);
  }
  while (tmp.endsWith(' ')) {
    tmp = tmp.substring(0, tmp.length - 1);
  }

  return tmp;
}
