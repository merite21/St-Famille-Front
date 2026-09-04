import '../models/prestation.dart';
import 'api_client.dart';

class PrestationService {
  PrestationService._();
  static final PrestationService instance = PrestationService._();

  Future<List<Prestation>> list() async {
    final data = await ApiClient.instance.get('/prestations');
    return (data as List)
        .map((item) => Prestation.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}
