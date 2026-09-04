import 'package:flutter/material.dart';

import '../../data/queue_directory.dart';
import '../../models/prise_en_charge.dart';
import '../../widgets/module_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_pill.dart';

class FileAttenteScreen extends StatefulWidget {
  const FileAttenteScreen({super.key});

  @override
  State<FileAttenteScreen> createState() => _FileAttenteScreenState();
}

class _FileAttenteScreenState extends State<FileAttenteScreen> {
  late List<PriseEnCharge> _entries;

  @override
  void initState() {
    super.initState();
    _entries = QueueDirectory.all;
  }

  void _refresh() {
    setState(() {
      _entries = QueueDirectory.all;
    });
  }

  void _advance(PriseEnCharge entry) {
    final next = switch (entry.statut) {
      'En attente' => 'En consultation',
      'En consultation' => 'Terminé',
      _ => entry.statut,
    };

    if (next == entry.statut) return;

    QueueDirectory.updateStatut(entry.id, next);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final enAttente = _entries.where((e) => e.statut == 'En attente').length;
    final enConsultation =
        _entries.where((e) => e.statut == 'En consultation').length;
    final termines = _entries.where((e) => e.statut == 'Terminé').length;

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
                    'Suivez et faites progresser les patients enregistrés à la réception.',
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
          const Text(
            'Patients dans la file',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          if (_entries.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  'Aucun patient dans la file d’attente. Enregistrez une arrivée depuis la Réception.',
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

  Widget _buildRow(PriseEnCharge entry) {
    final isTermine = entry.statut == 'Terminé';

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
            flex: 2,
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
          StatusPill(label: entry.statut, color: statusColor(entry.statut)),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: isTermine
                ? null
                : TextButton(
                    onPressed: () => _advance(entry),
                    child: Text(
                      entry.statut == 'En attente' ? 'Appeler' : 'Terminer',
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
