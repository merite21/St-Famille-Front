import '../models/patient.dart';
import 'api_client.dart';

class PatientService {
  PatientService._();
  static final PatientService instance = PatientService._();

  Future<List<Patient>> search({String? q}) async {
    final data = await ApiClient.instance.get(
      '/patients',
      query: {if (q != null && q.trim().isNotEmpty) 'q': q.trim(), 'per_page': 100},
    );
    final list = (data['data'] as List).cast<Map<String, dynamic>>();
    return list.map(Patient.fromJson).toList();
  }

  Future<int> total() async {
    final data = await ApiClient.instance.get('/patients', query: {'per_page': 1});
    return data['meta']['total'] as int;
  }

  Future<Patient> getById(int id) async {
    final data = await ApiClient.instance.get('/patients/$id');
    return Patient.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<Patient> create({
    required String nom,
    required String prenom,
    DateTime? dateNaissance,
    String? sexe,
    String? telephone,
    String? adresse,
    String? contactUrgence,
  }) async {
    final data = await ApiClient.instance.post('/patients', {
      'nom': nom,
      'prenom': prenom,
      if (dateNaissance != null)
        'date_naissance': _formatDate(dateNaissance),
      if (sexe != null) 'sexe': sexe,
      if (telephone != null && telephone.isNotEmpty) 'telephone': telephone,
      if (adresse != null && adresse.isNotEmpty) 'adresse': adresse,
      if (contactUrgence != null && contactUrgence.isNotEmpty)
        'contact_urgence': contactUrgence,
    });
    return Patient.fromJson(Map<String, dynamic>.from(data as Map));
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
