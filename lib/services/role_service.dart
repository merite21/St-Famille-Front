import '../models/role.dart';
import 'api_client.dart';

class RoleService {
  RoleService._();
  static final RoleService instance = RoleService._();

  Future<List<Role>> list() async {
    final data = await ApiClient.instance.get('/roles');
    return (data as List)
        .map((item) => Role.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}
