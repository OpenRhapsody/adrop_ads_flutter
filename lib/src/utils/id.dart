import 'dart:math';

String nanoid() {
  const alphabet =
      'ModuleSymbhasOwnPr0123456789ABCDEFGHNRVfgctiUvzKqYTJkLxpZXIjQW';
  const len = alphabet.length;
  int size = 21;

  String id = '';
  while (0 < size--) {
    id += alphabet[Random.secure().nextInt(len)];
  }
  return id;
}
