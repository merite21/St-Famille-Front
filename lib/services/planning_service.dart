import '../models/planning_entry.dart';
import 'api_client.dart';

class PlanningService {
  PlanningService._();
  static final PlanningService instance = PlanningService._();

  Future<List<PlanningEntry>> list({int? userId}) async {
    final data = await ApiClient.instance.get(
      '/plannings',
      query: {if (userId != null) 'user_id': userId},
    );
    return (data as List)
        .map((item) => PlanningEntry.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<PlanningEntry> create({
    required int userId,
    required DateTime dateDebut,
    required DateTime dateFin,
    String? service,
  }) async {
    final data = await ApiClient.instance.post('/plannings', {
      'user_id': userId,
      'date_debut': _formatDateTime(dateDebut),
      'date_fin': _formatDateTime(dateFin),
      if (service != null && service.isNotEmpty) 'service': service,
    });
    return PlanningEntry.fromJson(Map<String, dynamic>.from(data as Map));
  }

  String _formatDateTime(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)} '
        '${two(date.hour)}:${two(date.minute)}:00';
  }
}
