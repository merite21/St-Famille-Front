import '../models/dossier.dart';
import 'api_client.dart';

class DossierService {
  DossierService._();
  static final DossierService instance = DossierService._();

  Future<List<Dossier>> list({int? patientId, String? statut}) async {
    final data = await ApiClient.instance.get(
      '/dossiers',
      query: {
        if (patientId != null) 'patient_id': patientId,
        if (statut != null) 'statut': statut,
      },
    );
    return (data as List)
        .map((item) => Dossier.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<Dossier> create({required int patientId, String? motif}) async {
    final data = await ApiClient.instance.post('/dossiers', {
      'patient_id': patientId,
      if (motif != null && motif.isNotEmpty) 'motif': motif,
    });
    return Dossier.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<Dossier> getById(int id) async {
    final data = await ApiClient.instance.get('/dossiers/$id');
    return Dossier.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
