import '../models/file_attente_entry.dart';
import 'api_client.dart';

class FileAttenteService {
  FileAttenteService._();
  static final FileAttenteService instance = FileAttenteService._();

  Future<List<FileAttenteEntry>> list({String? statut, int? medecinId}) async {
    final data = await ApiClient.instance.get(
      '/file-attente',
      query: {
        if (statut != null) 'statut': statut,
        if (medecinId != null) 'medecin_id': medecinId,
      },
    );
    return (data as List)
        .map((item) => FileAttenteEntry.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<FileAttenteEntry> create({
    required int dossierId,
    String priorite = 'normale',
  }) async {
    final data = await ApiClient.instance.post('/file-attente', {
      'dossier_id': dossierId,
      'priorite': priorite,
    });
    return FileAttenteEntry.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<FileAttenteEntry> updateStatut(
    int id, {
    required String statut,
    int? medecinId,
  }) async {
    final data = await ApiClient.instance.put('/file-attente/$id', {
      'statut': statut,
      if (medecinId != null) 'medecin_id': medecinId,
    });
    return FileAttenteEntry.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
