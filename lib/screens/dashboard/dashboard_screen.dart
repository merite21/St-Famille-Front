import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/queue_directory.dart';
import '../../models/prise_en_charge.dart';
import '../../widgets/status_pill.dart';
import '../administration/administration_screen.dart';
import '../auth/login_screen.dart';
import '../consultations/consultations_screen.dart';
import '../paiements/paiements_screen.dart';
import '../patients/patients_screen.dart';
import '../planning/planning_screen.dart';
import '../reception/file_attente_screen.dart';
import '../reception/reception_screen.dart';
import '../soins/soins_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final int _selectedIndex = 0;

  final List<_MenuItem> _menuItems = const [
    _MenuItem(
      title: 'Tableau de bord',
      icon: Icons.dashboard_outlined,
    ),
    _MenuItem(
      title: 'Patients',
      icon: Icons.people_outline,
    ),
    _MenuItem(
      title: 'Réception',
      icon: Icons.how_to_reg_outlined,
    ),
    _MenuItem(
      title: 'Paiements',
      icon: Icons.payments_outlined,
    ),
    _MenuItem(
      title: 'File d’attente',
      icon: Icons.queue_outlined,
    ),
    _MenuItem(
      title: 'Consultations',
      icon: Icons.medical_services_outlined,
    ),
    _MenuItem(
      title: 'Soins infirmiers',
      icon: Icons.local_hospital_outlined,
    ),
    _MenuItem(
      title: 'Planning',
      icon: Icons.calendar_month_outlined,
    ),
    _MenuItem(
      title: 'Administration',
      icon: Icons.admin_panel_settings_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(
            color: Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 28),

          // Logo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_hospital_outlined,
                    color: AppTheme.primaryColor,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SAINTE FAMILLE',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Gestion hospitalière',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 35),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final selected = _selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: _buildMenuItem(
                    item: item,
                    selected: selected,
                    onTap: () {
                      if (index == 0) return;
                      _openModule(index);
                    },
                  ),
                );
              },
            ),
          ),

          // Utilisateur connecté
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'MA',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Utilisateur',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Administrateur',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Déconnexion',
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  icon: const Icon(
                    Icons.logout_outlined,
                    size: 19,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required _MenuItem item,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected
          ? AppTheme.primaryColor.withValues(alpha: 0.10)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
            vertical: 12,
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 21,
                color: selected
                    ? AppTheme.primaryColor
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected
                        ? AppTheme.primaryColor
                        : const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Ouvre l'écran du module correspondant à l'entrée sélectionnée dans
  /// le menu latéral (l'index 0, Tableau de bord, reste sur cet écran).
  void _openModule(int index) {
    final Widget screen;

    switch (index) {
      case 1:
        screen = const PatientsScreen();
        break;
      case 2:
        screen = const ReceptionScreen();
        break;
      case 3:
        screen = const PaiementsScreen();
        break;
      case 4:
        screen = const FileAttenteScreen();
        break;
      case 5:
        screen = const ConsultationsScreen();
        break;
      case 6:
        screen = const SoinsScreen();
        break;
      case 7:
        screen = const PlanningScreen();
        break;
      case 8:
        screen = const AdministrationScreen();
        break;
      default:
        return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        _buildTopBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: _buildDashboardBody(),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
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
          Text(
            _menuItems[_selectedIndex].title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),

          const Spacer(),

          // Recherche
          Container(
            width: 240,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                ),
                border: InputBorder.none,
                filled: false,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Notifications
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: Badge(
              label: const Text('3'),
              child: const Icon(
                Icons.notifications_none_outlined,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Profil
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

  Widget _buildDashboardBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bonjour, bienvenue 👋',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Voici un aperçu de l’activité de l’établissement.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
          ),
        ),

        const SizedBox(height: 28),

        // Statistiques
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final cardWidth = width > 1100
                ? (width - 48) / 4
                : width > 700
                    ? (width - 16) / 2
                    : width;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _buildStatCard(
                    title: 'Patients aujourd’hui',
                    value: '48',
                    icon: Icons.people_outline,
                    subtitle: '+8 depuis hier',
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildStatCard(
                    title: 'En attente',
                    value: '12',
                    icon: Icons.queue_outlined,
                    subtitle: 'File de consultation',
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildStatCard(
                    title: 'Consultations',
                    value: '31',
                    icon: Icons.medical_services_outlined,
                    subtitle: 'Aujourd’hui',
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildStatCard(
                    title: 'Soins en cours',
                    value: '7',
                    icon: Icons.local_hospital_outlined,
                    subtitle: 'Prise en charge infirmière',
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 28),

        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth > 850;

            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildQueueCard(),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 2,
                    child: _buildQuickActionsCard(),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _buildQueueCard(),
                const SizedBox(height: 20),
                _buildQuickActionsCard(),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueCard() {
    final entries = QueueDirectory.all.take(5).toList();

    return _buildSectionCard(
      title: 'File d’attente',
      trailing: TextButton(
        onPressed: () => _openModule(4),
        child: const Text('Voir tout'),
      ),
      child: entries.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Aucun patient dans la file d’attente pour le moment.',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            )
          : Column(
              children: entries.map(_buildQueueRow).toList(),
            ),
    );
  }

  Widget _buildQueueRow(PriseEnCharge entry) {
    final color = statusColor(entry.statut);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
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
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                entry.numero,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF475569),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.patient.nom} ${entry.patient.prenom}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  entry.service,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              entry.statut,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return _buildSectionCard(
      title: 'Accès rapides',
      child: Column(
        children: [
          _buildQuickAction(
            icon: Icons.person_add_alt_1_outlined,
            title: 'Nouveau patient',
            subtitle: 'Créer un dossier patient',
            onTap: () => _openModule(1),
          ),
          _buildQuickAction(
            icon: Icons.search,
            title: 'Rechercher un patient',
            subtitle: 'Ouvrir un dossier existant',
            onTap: () => _openModule(1),
          ),
          _buildQuickAction(
            icon: Icons.queue_outlined,
            title: 'File d’attente',
            subtitle: 'Gérer les patients en attente',
            onTap: () => _openModule(4),
          ),
          _buildQuickAction(
            icon: Icons.medical_services_outlined,
            title: 'Soins infirmiers',
            subtitle: 'Voir les demandes de soins',
            onTap: () => _openModule(6),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 21,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              size: 20,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _MenuItem {
  final String title;
  final IconData icon;

  const _MenuItem({
    required this.title,
    required this.icon,
  });
}