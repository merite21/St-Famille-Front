import 'patient.dart';

class Consultation {
  final String id;
  final Patient patient;
  final String medecin;
  final String motif;
  final DateTime dateHeure;
  final String statut;

  const Consultation({
    required this.id,
    required this.patient,
    required this.medecin,
    required this.motif,
    required this.dateHeure,
    required this.statut,
  });
}
