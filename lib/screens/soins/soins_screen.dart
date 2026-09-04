import 'package:flutter/material.dart';

import '../../data/patient_directory.dart';
import '../../models/patient.dart';
import '../../models/soin_infirmier.dart';
import '../../widgets/module_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_pill.dart';

const List<String> _typesSoin = [
  'Pansement',
  'Injection',
  'Perfusion',
  'Prise de constantes',
  'Autre',
];

class SoinsScreen extends StatefulWidget {
  const SoinsScreen({super.key});

  @override
  State<SoinsScreen> createState() => _SoinsScreenState();
}

class _SoinsScreenState extends State<SoinsScreen> {
  final List<SoinInfirmier> _soins = [];

  Future<void> _openCreateDialog() async {
    final created = await showDialog<SoinInfirmier>(
      context: context,
      builder: (context) => const _SoinDialog(),
    );

    if (created != null && mounted) {
      setState(() {
        _soins.insert(0, created);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final planifies = _soins.where((s) => s.statut == 'Planifié').length;
    final realises = _soins.where((s) => s.statut == 'Réalisé').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          const ModuleHeader(title: 'Soins infirmiers'),
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
                              'Soins infirmiers',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Planifiez et suivez les soins réalisés auprès des patients.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _openCreateDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Nouveau soin'),
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
                          title: 'Planifiés',
                          value: '$planifies',
                          icon: Icons.pending_actions_outlined,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: 'Réalisés',
                          value: '$realises',
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: 'Total',
                          value: '${_soins.length}',
                          icon: Icons.healing_outlined,
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
            'Soins enregistrés',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          if (_soins.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  'Aucun soin enregistré pour le moment.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            ..._soins.map(_buildRow),
        ],
      ),
    );
  }

  Widget _buildRow(SoinInfirmier soin) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${soin.patient.nom} ${soin.patient.prenom}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  soin.typeSoin,
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
              soin.infirmier,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ),
          Expanded(
            child: Text(
              _formatDateTime(soin.dateHeure),
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ),
          StatusPill(label: soin.statut, color: statusColor(soin.statut)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month à $hour:$minute';
  }
}

class _SoinDialog extends StatefulWidget {
  const _SoinDialog();

  @override
  State<_SoinDialog> createState() => _SoinDialogState();
}

class _SoinDialogState extends State<_SoinDialog> {
  final _formKey = GlobalKey<FormState>();
  final _infirmierController = TextEditingController();
  final _notesController = TextEditingController();

  Patient? _patient;
  String? _typeSoin;
  bool _isSaving = false;

  @override
  void dispose() {
    _infirmierController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patients = PatientDirectory.all;

    return AlertDialog(
      title: const Text('Nouveau soin'),
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
                'Type de soin',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _typeSoin,
                isExpanded: true,
                decoration: const InputDecoration(
                  hintText: 'Sélectionner un type de soin',
                  prefixIcon: Icon(Icons.healing_outlined),
                ),
                items: _typesSoin
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _typeSoin = value),
                validator: (value) =>
                    value == null ? 'Veuillez sélectionner un type' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Infirmier(ère)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _infirmierController,
                decoration: const InputDecoration(
                  hintText: 'Ex. Inf. Chantal Dossou',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Ce champ est obligatoire'
                    : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Notes (optionnel)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Observations complémentaires',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
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

    final notes = _notesController.text.trim();

    final soin = SoinInfirmier(
      id: 'SOIN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      patient: _patient!,
      typeSoin: _typeSoin!,
      infirmier: _infirmierController.text.trim(),
      dateHeure: DateTime.now(),
      statut: 'Planifié',
      notes: notes.isEmpty ? null : notes,
    );

    if (!mounted) return;

    Navigator.pop(context, soin);
  }
}
