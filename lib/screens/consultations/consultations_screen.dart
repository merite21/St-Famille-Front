import 'package:flutter/material.dart';

import '../../models/consultation.dart';
import '../../models/file_attente_entry.dart';
import '../../models/type_soin.dart';
import '../../models/utilisateur.dart';
import '../../services/api_exception.dart';
import '../../services/consultation_service.dart';
import '../../services/demande_soin_service.dart';
import '../../services/file_attente_service.dart';
import '../../services/type_soin_service.dart';
import '../../services/user_service.dart';
import '../../widgets/module_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_pill.dart';

const List<String> _orientations = ['sans_soins', 'avec_soins', 'autre'];

class ConsultationsScreen extends StatefulWidget {
  const ConsultationsScreen({super.key});

  @override
  State<ConsultationsScreen> createState() => _ConsultationsScreenState();
}

class _ConsultationsScreenState extends State<ConsultationsScreen> {
  List<Consultation> _consultations = [];
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
      final consultations = await ConsultationService.instance.list();
      if (!mounted) return;
      setState(() {
        _consultations = consultations;
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

  Future<void> _openCreateDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => const _ConsultationDialog(),
    );

    if (created == true) {
      _load();
    }
  }

  Future<void> _openDemandeSoinsDialog(Consultation consultation) async {
    List<TypeSoin> types;
    try {
      types = await TypeSoinService.instance.list();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }

    if (!mounted) return;

    TypeSoin? selected;
    final instructionsController = TextEditingController();
    bool isSaving = false;

    final created = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Demande de soins'),
            content: SizedBox(
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<TypeSoin>(
                    value: selected,
                    isExpanded: true,
                    decoration: const InputDecoration(hintText: 'Type de soin'),
                    items: types
                        .map((t) => DropdownMenuItem(value: t, child: Text(t.libelle)))
                        .toList(),
                    onChanged: (value) => setDialogState(() => selected = value),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: instructionsController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Instructions (optionnel)'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: (isSaving || selected == null)
                    ? null
                    : () async {
                        setDialogState(() => isSaving = true);
                        try {
                          await DemandeSoinService.instance.create(
                            dossierId: consultation.dossierId,
                            typeSoinId: selected!.id,
                            medecinId: consultation.medecinId,
                            consultationId: consultation.id,
                            instructions: instructionsController.text.trim(),
                          );
                          if (context.mounted) Navigator.pop(context, true);
                        } on ApiException catch (e) {
                          setDialogState(() => isSaving = false);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.message)),
                            );
                          }
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Envoyer'),
              ),
            ],
          );
        },
      ),
    );

    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Demande de soins envoyée à l’infirmier responsable.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sansSoins = _consultations.where((c) => c.orientation == 'sans_soins').length;
    final avecSoins = _consultations.where((c) => c.orientation == 'avec_soins').length;

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
                              'Consultez un patient depuis la file d’attente.',
                              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _openCreateDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Nouvelle consultation'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Total',
                          value: '${_consultations.length}',
                          icon: Icons.medical_services_outlined,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: 'Sans soins',
                          value: '$sansSoins',
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: 'Avec soins',
                          value: '$avecSoins',
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
            'Consultations enregistrées',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Column(
              children: [
                Text(_error!, style: const TextStyle(fontSize: 13, color: Color(0xFFDC2626))),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: _load, child: const Text('Réessayer')),
              ],
            )
          else if (_consultations.isEmpty)
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
                  consultation.motif?.isNotEmpty == true
                      ? consultation.motif!
                      : 'Dossier #${consultation.dossierId}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDateTime(consultation.debutAt),
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                ),
              ],
            ),
          ),
          StatusPill(
            label: statusLabel(consultation.orientation),
            color: statusColor(consultation.orientation),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 130,
            child: consultation.orientation == 'avec_soins'
                ? TextButton(
                    onPressed: () => _openDemandeSoinsDialog(consultation),
                    child: const Text('Demander un soin'),
                  )
                : null,
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
  final _motifController = TextEditingController();
  final _observationsController = TextEditingController();
  final _diagnosticController = TextEditingController();

  List<FileAttenteEntry> _entries = [];
  List<Utilisateur> _medecins = [];
  FileAttenteEntry? _selectedEntry;
  Utilisateur? _selectedMedecin;
  String _orientation = 'sans_soins';

  bool _loadingOptions = true;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  @override
  void dispose() {
    _motifController.dispose();
    _observationsController.dispose();
    _diagnosticController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    try {
      final results = await Future.wait([
        FileAttenteService.instance.list(statut: 'en_consultation'),
        UserService.instance.list(),
      ]);

      if (!mounted) return;

      setState(() {
        _entries = results[0] as List<FileAttenteEntry>;
        _medecins = (results[1] as List<Utilisateur>)
            .where((u) => u.role == 'medecin' && u.actif)
            .toList();
        _loadingOptions = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loadingOptions = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEntry == null || _selectedMedecin == null) {
      setState(() => _error = 'Veuillez sélectionner un patient et un médecin.');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await ConsultationService.instance.create(
        dossierId: _selectedEntry!.dossierId,
        medecinId: _selectedMedecin!.id,
        motif: _motifController.text.trim(),
        observations: _observationsController.text.trim(),
        diagnostic: _diagnosticController.text.trim(),
        orientation: _orientation,
      );

      // La consultation clôt le passage du patient dans la file d'attente.
      await FileAttenteService.instance.updateStatut(_selectedEntry!.id, statut: 'termine');

      if (context.mounted) Navigator.pop(context, true);
    } on ApiException catch (e) {
      setState(() {
        _isSaving = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvelle consultation'),
      content: SizedBox(
        width: 420,
        child: _loadingOptions
            ? const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              )
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_error != null) ...[
                        Text(_error!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12)),
                        const SizedBox(height: 8),
                      ],
                      const Text('Patient (file d’attente)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      if (_entries.isEmpty)
                        const Text(
                          'Aucun patient "en consultation" dans la file d’attente.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        )
                      else
                        DropdownButtonFormField<FileAttenteEntry>(
                          value: _selectedEntry,
                          isExpanded: true,
                          decoration: const InputDecoration(hintText: 'Sélectionner un patient'),
                          items: _entries
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(
                                    e.patientNom ?? 'Dossier #${e.dossierId}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(() => _selectedEntry = value),
                        ),
                      const SizedBox(height: 16),
                      const Text('Médecin',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Utilisateur>(
                        value: _selectedMedecin,
                        isExpanded: true,
                        decoration: const InputDecoration(hintText: 'Sélectionner un médecin'),
                        items: _medecins
                            .map((m) => DropdownMenuItem(value: m, child: Text(m.nomComplet)))
                            .toList(),
                        onChanged: (value) => setState(() => _selectedMedecin = value),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _motifController,
                        decoration: const InputDecoration(labelText: 'Motif'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _observationsController,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Observations (optionnel)'),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _diagnosticController,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Diagnostic (optionnel)'),
                      ),
                      const SizedBox(height: 16),
                      const Text('Orientation',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _orientation,
                        isExpanded: true,
                        items: _orientations
                            .map(
                              (o) => DropdownMenuItem(value: o, child: Text(statusLabel(o))),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => _orientation = value!),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context, false),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isSaving || _loadingOptions ? null : _save,
          child: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Enregistrer'),
        ),
      ],
    );
  }
}
