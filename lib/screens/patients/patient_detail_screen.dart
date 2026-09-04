import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/patient.dart';

class PatientDetailScreen extends StatelessWidget {
  final Patient patient;

  const PatientDetailScreen({
    super.key,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBreadcrumb(context),
                  const SizedBox(height: 22),
                  _buildPatientHeader(),
                  const SizedBox(height: 24),
                  _buildInformationSection(),
                  const SizedBox(height: 20),
                  _buildMedicalSection(),
                  const SizedBox(height: 20),
                  _buildHistorySection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Retour',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 8),
          const Text(
            'Dossier patient',
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

  Widget _buildBreadcrumb(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          child: const Text(
            'Patients',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            Icons.chevron_right,
            size: 17,
            color: Color(0xFF94A3B8),
          ),
        ),
        const Text(
          'Dossier patient',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildPatientHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor:
                AppTheme.primaryColor.withValues(alpha: 0.10),
            child: Text(
              patient.prenom.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${patient.nom} ${patient.prenom}',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildSmallInfo(
                      Icons.badge_outlined,
                      patient.id,
                    ),
                    const SizedBox(width: 18),
                    _buildSmallInfo(
                      Icons.person_outline,
                      '${patient.sexe} • ${patient.age} ans',
                    ),
                    const SizedBox(width: 18),
                    _buildSmallInfo(
                      Icons.phone_outlined,
                      patient.telephone,
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildStatusBadge(patient.statut),
        ],
      ),
    );
  }

  Widget _buildSmallInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF64748B),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF15803D),
        ),
      ),
    );
  }

  Widget _buildInformationSection() {
    return _buildSectionCard(
      title: 'Informations administratives',
      icon: Icons.person_outline,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Nom',
                  patient.nom,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Prénom',
                  patient.prenom,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Sexe',
                  patient.sexe,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Âge',
                  '${patient.age} ans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Téléphone',
                  patient.telephone,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Date de naissance',
                  'À renseigner',
                ),
              ),
              
     Expanded(
  child: _buildInfoItem(
                  'Adresse',
                  'À renseigner',
                ),
              ),
             Expanded(
  child: _buildInfoItem(
    'N° dossier',
    patient.id,
  ),
),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalSection() {
    return _buildSectionCard(
      title: 'Informations médicales',
      icon: Icons.medical_information_outlined,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMedicalCard(
                  title: 'Dernière consultation',
                  value: 'Aujourd’hui',
                  icon: Icons.calendar_today_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMedicalCard(
                  title: 'Consultations',
                  value: '8',
                  icon: Icons.medical_services_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMedicalCard(
                  title: 'Soins réalisés',
                  value: '5',
                  icon: Icons.healing_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMedicalCard(
                  title: 'Statut actuel',
                  value: 'Aucune prise en charge',
                  icon: Icons.check_circle_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Groupe sanguin',
                  'Non renseigné',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Allergies',
                  'Non renseignées',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Antécédents',
                  'Non renseignés',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Observations',
                  'Aucune',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
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

  Widget _buildHistorySection() {
    return _buildSectionCard(
      title: 'Historique des prises en charge',
      icon: Icons.history,
      child: Column(
        children: [
          _buildHistoryItem(
            date: '28/08/2026',
            type: 'Consultation médicale',
            description:
                'Consultation générale avec le médecin.',
            status: 'Terminée',
            icon: Icons.medical_services_outlined,
          ),
          _buildHistoryItem(
            date: '15/08/2026',
            type: 'Soin infirmier',
            description:
                'Soin réalisé en salle de soins 2.',
            status: 'Terminé',
            icon: Icons.healing_outlined,
          ),
          _buildHistoryItem(
            date: '02/08/2026',
            type: 'Consultation médicale',
            description:
                'Contrôle médical et suivi du patient.',
            status: 'Terminée',
            icon: Icons.medical_services_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({
    required String date,
    required String type,
    required String description,
    required String status,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF1F5F9),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 110,
            child: Text(
              date,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          _buildHistoryStatus(status),
        ],
      ),
    );
  }

  Widget _buildHistoryStatus(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Color(0xFF15803D),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}