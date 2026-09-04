import 'patient.dart';

class SoinInfirmier {
  final String id;
  final Patient patient;
  final String typeSoin;
  final String infirmier;
  final DateTime dateHeure;
  final String statut;
  final String? notes;

  const SoinInfirmier({
    required this.id,
    required this.patient,
    required this.typeSoin,
    required this.infirmier,
    required this.dateHeure,
    required this.statut,
    this.notes,
  });
}
