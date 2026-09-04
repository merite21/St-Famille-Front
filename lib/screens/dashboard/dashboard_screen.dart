import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/app_notification.dart';
import '../../models/file_attente_entry.dart';
import '../../models/role.dart';
import '../../services/api_exception.dart';
import '../../services/auth_service.dart';
import '../../services/demande_soin_service.dart';
import '../../services/file_attente_service.dart';
import '../../services/notification_service.dart';
import '../../services/patient_service.dart';
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

  bool _loadingStats = true;
  String? _statsError;
  int _totalPatients = 0;
  List<FileAttenteEntry> _queue = [];
  int _demandesSoinsEnAttente = 0;

  List<AppNotification> _notifications = [];

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
  void initState() {
    super.initState();
    _loadDashboardData();
    _loadNotifications();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _loadingStats = true;
      _statsError = null;
    });

    try {
      final results = await Future.wait([
        PatientService.instance.total(),
        FileAttenteService.instance.list(),
        DemandeSoinService.instance.list(statut: 'en_attente'),
      ]);

      if (!mounted) return;

      setState(() {
        _totalPatients = results[0] as int;
        _queue = results[1] as List<FileAttenteEntry>;
        _demandesSoinsEnAttente = (results[2] as List).length;
        _loadingStats = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _statsError = e.message;
        _loadingStats = false;
      });
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications = await NotificationService.instance.list(lu: false);
      if (!mounted) return;
      setState(() {
        _notifications = notifications;
      });
    } on ApiException {
      // Les notifications sont un confort, pas critique : on échoue en silence.
    }
  }

  Future<void> _openNotifications() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _NotificationsSheet(
        notifications: _notifications,
        onMarkRead: (notification) async {
          try {
            await NotificationService.instance.marquerLue(notification.id);
            if (!mounted) return;
            setState(() {
              _notifications = _notifications.where((n) => n.id != notification.id).toList();
            });
          } on ApiException catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.message), behavior: SnackBarBehavior.floating),
            );
          }
        },
      ),
    );
  }

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
    final user = AuthService.instance.currentUser;
    final initiales = user == null
        ? '?'
        : '${user.nom.isNotEmpty ? user.nom[0] : ''}${user.prenom.isNotEmpty ? user.prenom[0] : ''}'
            .toUpperCase();

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
                  child: Center(
                    child: Text(
                      initiales,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user == null ? 'Utilisateur' : user.nomComplet,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        user == null ? '' : roleLabel(user.role),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
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
                    AuthService.instance.logout();
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
  Future<void> _openModule(int index) async {
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

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );

    // Les données ont pu changer pendant que l'utilisateur était sur un
    // autre module (nouveau patient, file d'attente mise à jour...).
    if (mounted) {
      _loadDashboardData();
    }
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

          // Notifications
          IconButton(
            tooltip: 'Notifications',
            onPressed: _openNotifications,
            icon: Badge(
              label: Text('${_notifications.length}'),
              isLabelVisible: _notifications.isNotEmpty,
              child: const Icon(
                Icons.notifications_none_outlined,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Profil
          CircleAvatar(
            radius: 19,
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              _initialesUtilisateur(),
              style: const TextStyle(
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

  String _initialesUtilisateur() {
    final user = AuthService.instance.currentUser;
    if (user == null) return '?';
    return '${user.nom.isNotEmpty ? user.nom[0] : ''}${user.prenom.isNotEmpty ? user.prenom[0] : ''}'
        .toUpperCase();
  }

  Widget _buildDashboardBody() {
    final user = AuthService.instance.currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user == null ? 'Bonjour 👋' : 'Bonjour ${user.prenom} 👋',
          style: const TextStyle(
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

        if (_statsError != null) _buildStatsErrorBanner(),

        // Statistiques
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final cardWidth = width > 1100
                ? (width - 48) / 4
                : width > 700
                    ? (width - 16) / 2
                    : width;

            final enAttente =
                _queue.where((e) => e.statut == 'en_attente').length;
            final enConsultation =
                _queue.where((e) => e.statut == 'en_consultation').length;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _buildStatCard(
                    title: 'Patients enregistrés',
                    value: _loadingStats ? '…' : '$_totalPatients',
                    icon: Icons.people_outline,
                    subtitle: 'Au total',
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildStatCard(
                    title: 'En attente',
                    value: _loadingStats ? '…' : '$enAttente',
                    icon: Icons.queue_outlined,
                    subtitle: 'File de consultation',
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildStatCard(
                    title: 'En consultation',
                    value: _loadingStats ? '…' : '$enConsultation',
                    icon: Icons.medical_services_outlined,
                    subtitle: 'En ce moment',
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _buildStatCard(
                    title: 'Demandes de soins',
                    value: _loadingStats ? '…' : '$_demandesSoinsEnAttente',
                    icon: Icons.local_hospital_outlined,
                    subtitle: 'En attente d’attribution',
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

  Widget _buildStatsErrorBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _statsError!,
              style: const TextStyle(fontSize: 13, color: Color(0xFF991B1B)),
            ),
          ),
          TextButton(
            onPressed: _loadDashboardData,
            child: const Text('Réessayer'),
          ),
        ],
      ),
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
    final entries = _queue.take(5).toList();

    return _buildSectionCard(
      title: 'File d’attente',
      trailing: TextButton(
        onPressed: () => _openModule(4),
        child: const Text('Voir tout'),
      ),
      child: _loadingStats
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(child: CircularProgressIndicator()),
            )
          : entries.isEmpty
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

  Widget _buildQueueRow(FileAttenteEntry entry) {
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
                '#${entry.id}',
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
            child: Text(
              entry.patientNom ?? 'Dossier #${entry.dossierId}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
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
              statusLabel(entry.statut),
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
            icon: Icons.how_to_reg_outlined,
            title: 'Réception',
            subtitle: 'Enregistrer une arrivée',
            onTap: () => _openModule(2),
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

class _NotificationsSheet extends StatelessWidget {
  final List<AppNotification> notifications;
  final Future<void> Function(AppNotification) onMarkRead;

  const _NotificationsSheet({
    required this.notifications,
    required this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            if (notifications.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Aucune notification non lue.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        notification.contenu,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      trailing: IconButton(
                        tooltip: 'Marquer comme lue',
                        icon: const Icon(Icons.check_circle_outline, size: 20),
                        onPressed: () => onMarkRead(notification),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
