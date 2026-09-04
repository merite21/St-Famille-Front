import '../models/consultation.dart';
import 'api_client.dart';

class ConsultationService {
  ConsultationService._();
  static final ConsultationService instance = ConsultationService._();

  Future<List<Consultation>> list({int? dossierId, int? medecinId}) async {
    final data = await ApiClient.instance.get(
      '/consultations',
      query: {
        if (dossierId != null) 'dossier_id': dossierId,
        if (medecinId != null) 'medecin_id': medecinId,
      },
    );
    return (data as List)
        .map((item) => Consultation.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<Consultation> create({
    required int dossierId,
    required int medecinId,
    String? motif,
    String? observations,
    String? diagnostic,
    String orientation = 'sans_soins',
  }) async {
    final data = await ApiClient.instance.post('/consultations', {
      'dossier_id': dossierId,
      'medecin_id': medecinId,
      if (motif != null && motif.isNotEmpty) 'motif': motif,
      if (observations != null && observations.isNotEmpty) 'observations': observations,
      if (diagnostic != null && diagnostic.isNotEmpty) 'diagnostic': diagnostic,
      'orientation': orientation,
    });
    return Consultation.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<Consultation> update(
    int id, {
    String? motif,
    String? observations,
    String? diagnostic,
    String? orientation,
  }) async {
    final data = await ApiClient.instance.put('/consultations/$id', {
      if (motif != null) 'motif': motif,
      if (observations != null) 'observations': observations,
      if (diagnostic != null) 'diagnostic': diagnostic,
      if (orientation != null) 'orientation': orientation,
    });
    return Consultation.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
