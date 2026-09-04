import 'package:flutter/material.dart';

import '../../data/patient_directory.dart';
import '../../data/queue_directory.dart';
import '../../models/patient.dart';
import '../../models/prise_en_charge.dart';
import '../../widgets/module_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_pill.dart';

const List<String> _services = [
  'Consultation générale',
  'Pédiatrie',
  'Gynécologie',
  'Urgences',
  'Soins infirmiers',
];

class ReceptionScreen extends StatefulWidget {
  const ReceptionScreen({super.key});

  @override
  State<ReceptionScreen> createState() => _ReceptionScreenState();
}

class _ReceptionScreenState extends State<ReceptionScreen> {
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

  Future<void> _openCheckInDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => const _CheckInDialog(),
    );

    if (created == true) {
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final aujourdHui = _entries.length;
    final enAttente = _entries.where((e) => e.statut == 'En attente').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          const ModuleHeader(title: 'Réception'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Accueil des patients',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Enregistrez l’arrivée d’un patient et orientez-le vers le bon service.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _openCheckInDialog,
                        icon: const Icon(Icons.how_to_reg_outlined),
                        label: const Text('Nouvel enregistrement'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Arrivées aujourd’hui',
                          value: '$aujourdHui',
                          icon: Icons.how_to_reg_outlined,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: 'En attente d’orientation',
                          value: '$enAttente',
                          icon: Icons.hourglass_empty,
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
            'Derniers enregistrements',
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
                  'Aucun patient enregistré pour le moment.',
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
          Expanded(
            child: Text(
              _formatTime(entry.heureArrivee),
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ),
          StatusPill(label: entry.statut, color: statusColor(entry.statut)),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _CheckInDialog extends StatefulWidget {
  const _CheckInDialog();

  @override
  State<_CheckInDialog> createState() => _CheckInDialogState();
}

class _CheckInDialogState extends State<_CheckInDialog> {
  final _formKey = GlobalKey<FormState>();

  Patient? _patient;
  String? _service;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final patients = PatientDirectory.all;

    return AlertDialog(
      title: const Text('Nouvel enregistrement'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Patient',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<Patient>(
                value: _patient,
                isExpanded: true,
                decoration: const InputDecoration(
                  hintText: 'Sélectionner un patient',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                items: patients
                    .map(
                      (patient) => DropdownMenuItem(
                        value: patient,
                        child: Text(
                          '${patient.nom} ${patient.prenom} (${patient.id})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _patient = value),
                validator: (value) =>
                    value == null ? 'Veuillez sélectionner un patient' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Service',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _service,
                isExpanded: true,
                decoration: const InputDecoration(
                  hintText: 'Sélectionner un service',
                  prefixIcon: Icon(Icons.local_hospital_outlined),
                ),
                items: _services
                    .map(
                      (service) => DropdownMenuItem(
                        value: service,
                        child: Text(service),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _service = value),
                validator: (value) =>
                    value == null ? 'Veuillez sélectionner un service' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context, false),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Enregistrer'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Simulation temporaire.
    // Cette partie sera remplacée par l'appel à l'API REST PHP.
    await Future.delayed(const Duration(milliseconds: 600));

    QueueDirectory.checkIn(patient: _patient!, service: _service!);

    if (!mounted) return;

    Navigator.pop(context, true);
  }
}
