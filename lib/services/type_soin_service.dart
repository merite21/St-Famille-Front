import '../models/type_soin.dart';
import 'api_client.dart';

class TypeSoinService {
  TypeSoinService._();
  static final TypeSoinService instance = TypeSoinService._();

  Future<List<TypeSoin>> list() async {
    final data = await ApiClient.instance.get('/types-soins');
    return (data as List)
        .map((item) => TypeSoin.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}
