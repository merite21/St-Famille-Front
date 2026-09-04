import '../models/constantes.dart';
import 'api_client.dart';

class ConstantesService {
  ConstantesService._();
  static final ConstantesService instance = ConstantesService._();

  Future<Constantes> create(
    int dossierId, {
    double? temperature,
    int? tensionSystolique,
    int? tensionDiastolique,
    int? pouls,
    double? poids,
    double? taille,
    int? saturationO2,
  }) async {
    final data = await ApiClient.instance.post('/dossiers/$dossierId/constantes', {
      if (temperature != null) 'temperature': temperature,
      if (tensionSystolique != null) 'tension_systolique': tensionSystolique,
      if (tensionDiastolique != null) 'tension_diastolique': tensionDiastolique,
      if (pouls != null) 'pouls': pouls,
      if (poids != null) 'poids': poids,
      if (taille != null) 'taille': taille,
      if (saturationO2 != null) 'saturation_o2': saturationO2,
    });
    return Constantes.fromJson(Map<String, dynamic>.from(data as Map));
  }
}
