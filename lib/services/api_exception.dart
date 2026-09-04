/// Erreur renvoyée par l'API REST (ou levée localement en cas de
/// problème réseau), avec un message déjà adapté à l'affichage.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;

  const ApiException(
    this.message, {
    this.statusCode,
    this.errorCode,
  });

  @override
  String toString() => message;
}
