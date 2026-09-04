import '../models/attribution_soin.dart';
import 'api_client.dart';

class AttributionSoinService {
  AttributionSoinService._();
  static final AttributionSoinService instance = AttributionSoinService._();

  Future<AttributionSoin> create({
    required int demandeSoinId,
    required int infirmierId,
    int? salleSoinId,
  }) async {
    final data = await ApiClient.instance.post('/attributions-soins', {
      'demande_soin_id': demandeSoinId,
      'infirmier_id': infirmierId,
      if (salleSoinId != null) 'salle_soin_id': salleSoinId,
    });
    return AttributionSoin.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<AttributionSoin> getById(int id) async {
    final data = await ApiClient.instance.get('/attributions-soins/$id');
    return AttributionSoin.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<AttributionSoin> updateStatut(int id, String statut) async {
    final data = await ApiClient.instance.put('/attributions-soins/$id', {
      'statut': statut,
    });
    return AttributionSoin.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
