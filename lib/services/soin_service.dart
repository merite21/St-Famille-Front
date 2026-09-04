import '../models/soin.dart';
import 'api_client.dart';

class SoinService {
  SoinService._();
  static final SoinService instance = SoinService._();

  Future<Soin> update(
    int id, {
    String? soinRealise,
    String? observations,
    String? incident,
    String? commentaire,
    bool? valide,
  }) async {
    final data = await ApiClient.instance.put('/soins/$id', {
      if (soinRealise != null) 'soin_realise': soinRealise,
      if (observations != null) 'observations': observations,
      if (incident != null) 'incident': incident,
      if (commentaire != null) 'commentaire': commentaire,
      if (valide != null) 'valide': valide,
    });
    return Soin.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
