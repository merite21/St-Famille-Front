import '../services/json_helpers.dart';

class TypeSoin {
  final int id;
  final String libelle;

  const TypeSoin({required this.id, required this.libelle});

  factory TypeSoin.fromJson(Map<String, dynamic> json) {
    return TypeSoin(
      id: parseApiInt(json['id'])!,
      libelle: json['libelle'] as String,
    );
  }
}
