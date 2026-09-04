import '../models/salle_soin.dart';
import 'api_client.dart';

class SalleSoinService {
  SalleSoinService._();
  static final SalleSoinService instance = SalleSoinService._();

  Future<List<SalleSoin>> list() async {
    final data = await ApiClient.instance.get('/salles-soins');
    return (data as List)
        .map((item) => SalleSoin.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}
