import 'package:flutter/material.dart';

import '../../models/file_attente_entry.dart';
import '../../models/utilisateur.dart';
import '../../services/api_exception.dart';
import '../../services/file_attente_service.dart';
import '../../services/user_service.dart';
import '../../widgets/module_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_pill.dart';

class FileAttenteScreen extends StatefulWidget {
  const FileAttenteScreen({super.key});

  @override
  State<FileAttenteScreen> createState() => _FileAttenteScreenState();
}

class _FileAttenteScreenState extends State<FileAttenteScreen> {
  List<FileAttenteEntry> _entries = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final entries = await FileAttenteService.instance.list();
      if (!mounted) return;
      setState(() {
        _entries = entries;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _advance(FileAttenteEntry entry) async {
    switch (entry.statut) {
      case 'en_attente':
        await _appelerPatient(entry);
        break;
      case 'appele':
        await _updateStatut(entry, 'en_consultation');
        break;
      case 'en_consultation':
        await _updateStatut(entry, 'termine');
        break;
    }
  }

  Future<void> _appelerPatient(FileAttenteEntry entry) async {
    List<Utilisateur> medecins;
    try {
      final users = await UserService.instance.list();
      medecins = users.where((u) => u.role == 'medecin' && u.actif).toList();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }

    if (!mounted) return;

    final selected = await showDialog<Utilisateur>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Appeler le patient — choisir le médecin'),
        children: medecins.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Text('Aucun médecin actif enregistré.'),
                ),
              ]
            : medecins
                .map(
                  (m) => SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, m),
                    child: Text(m.nomComplet),
                  ),
                )
                .toList(),
      ),
    );

    if (selected == null) return;

    await _updateStatut(entry, 'appele', medecinId: selected.id);
  }

  Future<void> _updateStatut(FileAttenteEntry entry, String statut, {int? medecinId}) async {
    try {
      await FileAttenteService.instance.updateStatut(
        entry.id,
        statut: statut,
        medecinId: medecinId,
      );
      _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final enAttente = _entries.where((e) => e.statut == 'en_attente').length;
    final appele = _entries.where((e) => e.statut == 'appele').length;
    final enConsultation = _entries.where((e) => e.statut == 'en_consultation').length;
    final termines = _entries.where((e) => e.statut == 'termine').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          const ModuleHeader(title: 'File d’attente'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Suivi de la file d’attente',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Patients envoyés en file d’attente après confirmation de paiement.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'En attente',
                          value: '$enAttente',
                          icon: Icons.hourglass_empty,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: 'Appelés',
                          value: '$appele',
                          icon: Icons.campaign_outlined,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: 'En consultation',
                          value: '$enConsultation',
                          icon: Icons.medical_services_outlined,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: 'Terminés',
                          value: '$termines',
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Patients dans la file',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Actualiser',
                onPressed: _load,
                icon: const Icon(Icons.refresh, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  Text(_error!, style: const TextStyle(fontSize: 13, color: Color(0xFFDC2626))),
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: _load, child: const Text('Réessayer')),
                ],
              ),
            )
          else if (_entries.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  'Aucun patient dans la file d’attente. Envoyez un dossier après confirmation de paiement.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            ..._entries.map(_buildRow),
        ],
      ),
    );
  }

  Widget _buildRow(FileAttenteEntry entry) {
    final isTermine = entry.statut == 'termine' || entry.statut == 'annule';

    String actionLabel() {
      switch (entry.statut) {
        case 'en_attente':
          return 'Appeler';
        case 'appele':
          return 'Démarrer';
        case 'en_consultation':
          return 'Terminer';
        default:
          return '';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
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
            flex: 2,
            child: Text(
              entry.patientNom ?? 'Dossier #${entry.dossierId}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          if (entry.priorite == 'urgente')
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.priority_high, size: 16, color: Color(0xFFDC2626)),
            ),
          StatusPill(label: statusLabel(entry.statut), color: statusColor(entry.statut)),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: isTermine
                ? null
                : TextButton(
                    onPressed: () => _advance(entry),
                    child: Text(actionLabel()),
                  ),
          ),
        ],
      ),
    );
  }
}
