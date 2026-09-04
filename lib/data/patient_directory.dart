import '../models/patient.dart';

/// Source de données partagée des patients pour la maquette.
///
/// En attendant l'intégration de l'API REST PHP (GET/POST /api/patients),
/// ce dépôt en mémoire centralise les patients afin que tous les modules
/// (Réception, Paiements, Consultations, Soins, Planning...) référencent
/// la même liste que l'écran Patients.
class PatientDirectory {
  PatientDirectory._();

  static final List<Patient> _patients = [
    const Patient(
      id: 'SF-2026-0001',
      nom: 'ADEKUNLE',
      prenom: 'Jean',
      sexe: 'Homme',
      age: 34,
      telephone: '97 00 00 01',
      statut: 'Actif',
    ),
    const Patient(
      id: 'SF-2026-0002',
      nom: 'AHOYO',
      prenom: 'Marie',
      sexe: 'Femme',
      age: 28,
      telephone: '96 00 00 02',
      statut: 'Actif',
    ),
    const Patient(
      id: 'SF-2026-0003',
      nom: 'ASSOGBA',
      prenom: 'Paul',
      sexe: 'Homme',
      age: 46,
      telephone: '95 00 00 03',
      statut: 'Actif',
    ),
    const Patient(
      id: 'SF-2026-0004',
      nom: 'GBETO',
      prenom: 'Grâce',
      sexe: 'Femme',
      age: 39,
      telephone: '94 00 00 04',
      statut: 'Actif',
    ),
    const Patient(
      id: 'SF-2026-0005',
      nom: 'HOUNKPE',
      prenom: 'David',
      sexe: 'Homme',
      age: 51,
      telephone: '90 00 00 05',
      statut: 'Actif',
    ),
  ];

  static List<Patient> get all => List.unmodifiable(_patients);

  static void add(Patient patient) {
    _patients.insert(0, patient);
  }
}
