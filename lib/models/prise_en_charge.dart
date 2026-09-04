import 'patient.dart';

class PriseEnCharge {
  final String id;
  final Patient patient;
  final String service;
  final String numero;
  final String statut;
  final DateTime heureArrivee;
  final String? medecin;

  const PriseEnCharge({
    required this.id,
    required this.patient,
    required this.service,
    required this.numero,
    required this.statut,
    required this.heureArrivee,
    this.medecin,
  });

  PriseEnCharge copyWith({
    String? statut,
    String? medecin,
  }) {
    return PriseEnCharge(
      id: id,
      patient: patient,
      service: service,
      numero: numero,
      statut: statut ?? this.statut,
      heureArrivee: heureArrivee,
      medecin: medecin ?? this.medecin,
    );
  }
}
