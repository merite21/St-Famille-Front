import '../services/json_helpers.dart';

/// Nommé "AppNotification" pour éviter toute confusion avec le widget
/// Flutter `Notification`.
class AppNotification {
  final int id;
  final String type;
  final String contenu;
  final String? lienRessource;
  final bool lu;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.contenu,
    required this.createdAt,
    this.lienRessource,
    this.lu = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: parseApiInt(json['id'])!,
      type: json['type'] as String,
      contenu: json['contenu'] as String,
      lienRessource: json['lien_ressource'] as String?,
      lu: parseApiBool(json['lu']),
      createdAt: parseApiDate(json['created_at'])!,
    );
  }
}
