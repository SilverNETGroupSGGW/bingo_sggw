import 'dart:math';

/// Generuje krótki, czytelny kod pokoju (bez znaków łatwych do pomylenia: 0/O, 1/I).
String generateRoomCode({int length = 6}) {
  const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  final random = Random.secure();
  return List.generate(
    length,
    (_) => alphabet[random.nextInt(alphabet.length)],
  ).join();
}
