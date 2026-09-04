import '../models/demande_soin.dart';
import 'api_client.dart';

class DemandeSoinService {
  DemandeSoinService._();
  static final DemandeSoinService instance = DemandeSoinService._();

  Future<List<DemandeSoin>> list({String? statut}) async {
    final data = await ApiClient.instance.get(
      '/demandes-soins',
      query: {if (statut != null) 'statut': statut},
    );
    return (data as List)
        .map((item) => DemandeSoin.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<DemandeSoin> create({
    required int dossierId,
    required int typeSoinId,
    required int medecinId,
    int? consultationId,
    String priorite = 'normale',
    String? instructions,
  }) async {
    final data = await ApiClient.instance.post('/demandes-soins', {
      'dossier_id': dossierId,
      'type_soin_id': typeSoinId,
      'medecin_id': medecinId,
      if (consultationId != null) 'consultation_id': consultationId,
      'priorite': priorite,
      if (instructions != null && instructions.isNotEmpty) 'instructions': instructions,
    });
    return DemandeSoin.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
