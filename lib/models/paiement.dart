import 'patient.dart';

class Paiement {
  final String id;
  final Patient patient;
  final double montant;
  final String methode;
  final String motif;
  final String statut;
  final DateTime date;

  const Paiement({
    required this.id,
    required this.patient,
    required this.montant,
    required this.methode,
    required this.motif,
    required this.statut,
    required this.date,
  });
}
