import '../models/garde.dart';
import 'api_client.dart';

class GardeService {
  GardeService._();
  static final GardeService instance = GardeService._();

  Future<List<Garde>> list({DateTime? date}) async {
    final data = await ApiClient.instance.get(
      '/gardes',
      query: {if (date != null) 'date': _formatDate(date)},
    );
    return (data as List)
        .map((item) => Garde.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<Garde> create({
    required int userId,
    required DateTime dateGarde,
    required String typeGarde,
  }) async {
    final data = await ApiClient.instance.post('/gardes', {
      'user_id': userId,
      'date_garde': _formatDate(dateGarde),
      'type_garde': typeGarde,
    });
    return Garde.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<Garde> updateStatut(int id, String statut) async {
    final data = await ApiClient.instance.put('/gardes/$id', {'statut': statut});
    return Garde.fromJson(Map<String, dynamic>.from(data as Map));
  }

  String _formatDate(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }
}
