import 'package:flutter/material.dart';

import '../../data/patient_directory.dart';
import '../../models/patient.dart';
import '../../models/rendez_vous.dart';
import '../../widgets/module_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_pill.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  final List<RendezVous> _rendezVous = [];

  Future<void> _openCreateDialog() async {
    final created = await showDialog<RendezVous>(
      context: context,
      builder: (context) => const _RendezVousDialog(),
    );

    if (created != null && mounted) {
      setState(() {
        _rendezVous.insert(0, created);
        _rendezVous.sort((a, b) => a.dateHeure.compareTo(b.dateHeure));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final aujourdHui = _rendezVous.where((r) {
      return r.dateHeure.year == now.year &&
          r.dateHeure.month == now.month &&
          r.dateHeure.day == now.day;
    }).length;
    final confirmes = _rendezVous.where((r) => r.statut == 'Confirmé').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          const ModuleHeader(title: 'Planning'),
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
                              'Planning des rendez-vous',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Planifiez les rendez-vous des patients avec les médecins.',
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
                        label: const Text('Nouveau rendez-vous'),
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
                          title: 'Aujourd’hui',
                          value: '$aujourdHui',
                          icon: Icons.today_outlined,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: 'Confirmés',
                          value: '$confirmes',
                          icon: Icons.event_available_outlined,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: 'Total planifiés',
                          value: '${_rendezVous.length}',
                          icon: Icons.calendar_month_outlined,
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
            'Rendez-vous planifiés',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          if (_rendezVous.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  'Aucun rendez-vous planifié pour le moment.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            ..._rendezVous.map(_buildRow),
        ],
      ),
    );
  }

  Widget _buildRow(RendezVous rendezVous) {
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
                  '${rendezVous.patient.nom} ${rendezVous.patient.prenom}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  rendezVous.motif,
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
              rendezVous.medecin,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ),
          Expanded(
            child: Text(
              _formatDateTime(rendezVous.dateHeure),
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ),
          StatusPill(
            label: rendezVous.statut,
            color: statusColor(rendezVous.statut),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year} à $hour:$minute';
  }
}

class _RendezVousDialog extends StatefulWidget {
  const _RendezVousDialog();

  @override
  State<_RendezVousDialog> createState() => _RendezVousDialogState();
}

class _RendezVousDialogState extends State<_RendezVousDialog> {
  final _formKey = GlobalKey<FormState>();
  final _medecinController = TextEditingController();
  final _motifController = TextEditingController();

  Patient? _patient;
  DateTime? _dateHeure;
  bool _isSaving = false;

  @override
  void dispose() {
    _medecinController.dispose();
    _motifController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Sélectionner la date',
      cancelText: 'Annuler',
      confirmText: 'Valider',
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Sélectionner l’heure',
      cancelText: 'Annuler',
      confirmText: 'Valider',
    );

    if (time == null) return;

    setState(() {
      _dateHeure = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year} à $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final patients = PatientDirectory.all;

    return AlertDialog(
      title: const Text('Nouveau rendez-vous'),
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
                'Médecin',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _medecinController,
                decoration: const InputDecoration(
                  hintText: 'Ex. Dr. Fatou Kone',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Ce champ est obligatoire'
                    : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Motif',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _motifController,
                decoration: const InputDecoration(
                  hintText: 'Ex. Suivi post-consultation',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Ce champ est obligatoire'
                    : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Date et heure',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDateTime,
                borderRadius: BorderRadius.circular(10),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    hintText: 'JJ/MM/AAAA à HH:MM',
                    prefixIcon: Icon(Icons.event_outlined),
                  ),
                  child: Text(
                    _dateHeure == null
                        ? 'Sélectionner une date et une heure'
                        : _formatDateTime(_dateHeure!),
                    style: TextStyle(
                      fontSize: 14,
                      color: _dateHeure == null
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF334155),
                    ),
                  ),
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

    if (_dateHeure == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une date et une heure.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Simulation temporaire.
    // Cette partie sera remplacée par l'appel à l'API REST PHP.
    await Future.delayed(const Duration(milliseconds: 600));

    final rendezVous = RendezVous(
      id: 'RDV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      patient: _patient!,
      medecin: _medecinController.text.trim(),
      motif: _motifController.text.trim(),
      dateHeure: _dateHeure!,
      statut: 'Confirmé',
    );

    if (!mounted) return;

    Navigator.pop(context, rendezVous);
  }
}
