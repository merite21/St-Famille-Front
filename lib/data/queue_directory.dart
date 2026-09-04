import '../models/patient.dart';
import '../models/prise_en_charge.dart';

/// File d'attente partagée entre la Réception (enregistrement des
/// arrivées) et l'écran File d'attente (suivi en temps réel), afin que
/// les deux modules reflètent le même état.
///
/// À remplacer par un service consommant l'API REST PHP lors de
/// l'intégration back-end (GET/POST /api/prises-en-charge).
class QueueDirectory {
  QueueDirectory._();

  static final List<PriseEnCharge> _entries = [];
  static int _counter = 0;

  static List<PriseEnCharge> get all => List.unmodifiable(_entries);

  static PriseEnCharge checkIn({
    required Patient patient,
    required String service,
    String? medecin,
  }) {
    _counter++;

    final entry = PriseEnCharge(
      id: 'PEC-${_counter.toString().padLeft(3, '0')}',
      patient: patient,
      service: service,
      numero: _counter.toString().padLeft(2, '0'),
      statut: 'En attente',
      heureArrivee: DateTime.now(),
      medecin: medecin,
    );

    _entries.insert(0, entry);
    return entry;
  }

  static void updateStatut(String id, String statut) {
    final index = _entries.indexWhere((entry) => entry.id == id);

    if (index == -1) return;

    _entries[index] = _entries[index].copyWith(statut: statut);
  }
}
