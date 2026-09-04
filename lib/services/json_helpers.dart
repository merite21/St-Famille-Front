/// Petits convertisseurs tolérants pour les réponses de l'API PHP.
///
/// PDO renvoie les colonnes DECIMAL (montants, constantes...) sous forme
/// de chaînes dans le JSON (ex. "montant_fcfa": "7000"), jamais de
/// nombres JSON natifs : ces helpers évitent une exception de cast à
/// chaque lecture de ce type de champ.
library;

DateTime? parseApiDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

double? parseApiDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int? parseApiInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

bool parseApiBool(dynamic value) {
  return value == 1 || value == true || value == '1';
}
