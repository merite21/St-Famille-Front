import 'package:flutter/material.dart';

import '../../data/patient_directory.dart';
import '../../models/consultation.dart';
import '../../models/patient.dart';
import '../../widgets/module_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_pill.dart';

class ConsultationsScreen extends StatefulWidget {
  const ConsultationsScreen({super.key});

  @override
  State<ConsultationsScreen> createState() => _ConsultationsScreenState();
}

class _ConsultationsScreenState extends State<ConsultationsScreen> {
  final List<Consultation> _consultations = [];

  Future<void> _openCreateDialog() async {
    final created = await showDialog<Consultation>(
      context: context,
      builder: (context) => const _ConsultationDialog(),
    );

    if (created != null && mounted) {
      setState(() {
        _consultations.insert(0, created);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final programmees =
        _consultations.where((c) => c.statut == 'Programmée').length;
    final terminees =
        _consultations.where((c) => c.statut == 'Terminée').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          const ModuleHeader(title: 'Consultations'),
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
                              'Consultations médicales',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Planifiez et suivez les consultations des patients.',
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
                        label: const Text('Nouvelle consultation'),
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
                          title: 'Programmées',
                          value: '$programmees',
                          icon: Icons.event_available_outlined,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: 'Terminées',
                          value: '$terminees',
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: 'Total',
                          value: '${_consultations.length}',
                          icon: Icons.medical_services_outlined,
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
            'Consultations enregistrées',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          if (_consultations.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  'Aucune consultation enregistrée pour le moment.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            ..._consultations.map(_buildRow),
        ],
      ),
    );
  }

  Widget _buildRow(Consultation consultation) {
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
                  '${consultation.patient.nom} ${consultation.patient.prenom}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  consultation.motif,
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
              consultation.medecin,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ),
          Expanded(
            child: Text(
              _formatDateTime(consultation.dateHeure),
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ),
          StatusPill(
            label: consultation.statut,
            color: statusColor(consultation.statut),
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
    return '$day/$month à $hour:$minute';
  }
}

class _ConsultationDialog extends StatefulWidget {
  const _ConsultationDialog();

  @override
  State<_ConsultationDialog> createState() => _ConsultationDialogState();
}

class _ConsultationDialogState extends State<_ConsultationDialog> {
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
      firstDate: now.subtract(const Duration(days: 1)),
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
      title: const Text('Nouvelle consultation'),
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
                  hintText: 'Ex. Douleurs abdominales',
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

    final consultation = Consultation(
      id: 'CONS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      patient: _patient!,
      medecin: _medecinController.text.trim(),
      motif: _motifController.text.trim(),
      dateHeure: _dateHeure!,
      statut: 'Programmée',
    );

    if (!mounted) return;

    Navigator.pop(context, consultation);
  }
}
