import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/patient.dart';
import 'patient_detail_screen.dart';
import 'create_patient_screen.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  final List<Patient> _patients = [
    Patient(
      id: 'SF-2026-0001',
      nom: 'ADEKUNLE',
      prenom: 'Jean',
      sexe: 'Homme',
      age: 34,
      telephone: '97 00 00 01',
      statut: 'Actif',
    ),
    Patient(
      id: 'SF-2026-0002',
      nom: 'AHOYO',
      prenom: 'Marie',
      sexe: 'Femme',
      age: 28,
      telephone: '96 00 00 02',
      statut: 'Actif',
    ),
    Patient(
      id: 'SF-2026-0003',
      nom: 'ASSOGBA',
      prenom: 'Paul',
      sexe: 'Homme',
      age: 46,
      telephone: '95 00 00 03',
      statut: 'Actif',
    ),
    Patient(
      id: 'SF-2026-0004',
      nom: 'GBETO',
      prenom: 'Grâce',
      sexe: 'Femme',
      age: 39,
      telephone: '94 00 00 04',
      statut: 'Actif',
    ),
    Patient(
      id: 'SF-2026-0005',
      nom: 'HOUNKPE',
      prenom: 'David',
      sexe: 'Homme',
      age: 51,
      telephone: '90 00 00 05',
      statut: 'Actif',
    ),
  ];

  Future<void> _openCreatePatient() async {
    final patient = await Navigator.of(context).push<Patient>(
      MaterialPageRoute(builder: (context) => const CreatePatientScreen()),
    );

    if (patient == null || !mounted) {
      return;
    }

    setState(() {
      _patients.insert(0, patient);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Le dossier de ${patient.nom} ${patient.prenom} a été créé.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Patient> get _filteredPatients {
    if (_searchQuery.trim().isEmpty) {
      return _patients;
    }

    final query = _searchQuery.toLowerCase().trim();

    return _patients.where((patient) {
      return patient.nom.toLowerCase().contains(query) ||
          patient.prenom.toLowerCase().contains(query) ||
          patient.id.toLowerCase().contains(query) ||
          patient.telephone.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPageIntroduction(),

                  const SizedBox(height: 24),

                  _buildStatistics(),

                  const SizedBox(height: 24),

                  _buildPatientList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          const Text(
            'Patients',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),

          const Spacer(),

          IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_outlined),
          ),

          const SizedBox(width: 10),

          const CircleAvatar(
            radius: 19,
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              'MA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIntroduction() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gestion des patients',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Rechercher, créer et consulter les dossiers patients.',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),

        ElevatedButton.icon(
          onPressed: _openCreatePatient,
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Nouveau patient'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total patients',
            value: '1 248',
            icon: Icons.people_outline,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Nouveaux aujourd’hui',
            value: '18',
            icon: Icons.person_add_alt_1_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Dossiers actifs',
            value: '1 196',
            icon: Icons.folder_open_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Prises en charge',
            value: '34',
            icon: Icons.medical_services_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 23),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientList() {
    final patients = _filteredPatients;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'Dossiers patients',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${patients.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 300,
                height: 42,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Rechercher un patient...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            icon: const Icon(Icons.close, size: 18),
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (patients.isEmpty)
            _buildEmptyState()
          else
            _buildPatientsTable(patients),
        ],
      ),
    );
  }

  Widget _buildPatientsTable(List<Patient> patients) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: const Row(
            children: [
              SizedBox(
                width: 125,
                child: Text('N° DOSSIER', style: _tableHeaderStyle),
              ),
              Expanded(
                flex: 2,
                child: Text('PATIENT', style: _tableHeaderStyle),
              ),
              Expanded(child: Text('SEXE / ÂGE', style: _tableHeaderStyle)),
              Expanded(
                flex: 2,
                child: Text('TÉLÉPHONE', style: _tableHeaderStyle),
              ),
              SizedBox(
                width: 90,
                child: Text('STATUT', style: _tableHeaderStyle),
              ),
              SizedBox(width: 55, child: Text('', style: _tableHeaderStyle)),
            ],
          ),
        ),

        ...patients.map(_buildPatientRow),
      ],
    );
  }

  Widget _buildPatientRow(Patient patient) {
    return InkWell(
      onTap: () {
        _showPatientDetails(patient);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 125,
              child: Text(
                patient.id,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),

            Expanded(
              flex: 2,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: AppTheme.primaryColor.withValues(
                      alpha: 0.10,
                    ),
                    child: Text(
                      patient.prenom.substring(0, 1),
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${patient.nom} ${patient.prenom}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Text(
                '${patient.sexe} / ${patient.age} ans',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),

            Expanded(
              flex: 2,
              child: Text(
                patient.telephone,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),

            SizedBox(
              width: 90,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Actif',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF15803D),
                  ),
                ),
              ),
            ),

            SizedBox(
              width: 55,
              child: IconButton(
                tooltip: 'Voir le dossier',
                onPressed: () {
                  _showPatientDetails(patient);
                },
                icon: const Icon(Icons.arrow_forward_ios, size: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.search_off_outlined, size: 45, color: Color(0xFF94A3B8)),
          SizedBox(height: 12),
          Text(
            'Aucun patient trouvé',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Essayez une autre recherche.',
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  void _showPatientDetails(Patient patient) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PatientDetailScreen(patient: patient),
      ),
    );
  }
}

const TextStyle _tableHeaderStyle = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.w700,
  color: Color(0xFF64748B),
);
