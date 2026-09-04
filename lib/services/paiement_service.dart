import '../models/paiement.dart';
import 'api_client.dart';

class PaiementService {
  PaiementService._();
  static final PaiementService instance = PaiementService._();

  Future<List<Paiement>> list({String? statut, int? dossierId}) async {
    final data = await ApiClient.instance.get(
      '/paiements',
      query: {
        if (statut != null) 'statut': statut,
        if (dossierId != null) 'dossier_id': dossierId,
      },
    );
    return (data as List)
        .map((item) => Paiement.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<Paiement> create({
    required int dossierId,
    required int prestationId,
  }) async {
    final data = await ApiClient.instance.post('/paiements', {
      'dossier_id': dossierId,
      'prestation_id': prestationId,
    });
    return Paiement.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<Paiement> confirmer(int id, {String? referenceExterne}) async {
    final data = await ApiClient.instance.put('/paiements/$id/confirmer', {
      if (referenceExterne != null && referenceExterne.isNotEmpty)
        'reference_externe': referenceExterne,
    });
    return Paiement.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<Paiement> getById(int id) async {
    final data = await ApiClient.instance.get('/paiements/$id');
    return Paiement.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
