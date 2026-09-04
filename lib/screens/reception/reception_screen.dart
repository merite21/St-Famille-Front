import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/dossier.dart';
import '../../models/patient.dart';
import '../../services/api_exception.dart';
import '../../services/constantes_service.dart';
import '../../services/dossier_service.dart';
import '../../services/patient_service.dart';
import '../../widgets/module_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_pill.dart';
import '../patients/create_patient_screen.dart';

class ReceptionScreen extends StatefulWidget {
  const ReceptionScreen({super.key});

  @override
  State<ReceptionScreen> createState() => _ReceptionScreenState();
}

class _ReceptionScreenState extends State<ReceptionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _motifController = TextEditingController();
  Timer? _debounce;

  List<Patient> _searchResults = [];
  bool _searching = false;
  Patient? _selectedPatient;

  List<Dossier> _recentDossiers = [];
  bool _loadingRecent = true;
  bool _isOpeningDossier = false;

  @override
  void initState() {
    super.initState();
    _loadRecentDossiers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _motifController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadRecentDossiers() async {
    setState(() => _loadingRecent = true);
    try {
      final dossiers = await DossierService.instance.list(statut: 'ouvert');
      if (!mounted) return;
      setState(() {
        _recentDossiers = dossiers;
        _loadingRecent = false;
      });
    } on ApiException {
      if (!mounted) return;
      setState(() => _loadingRecent = false);
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    if (value.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 350), () async {
      setState(() => _searching = true);
      try {
        final results = await PatientService.instance.search(q: value);
        if (!mounted) return;
        setState(() {
          _searchResults = results;
          _searching = false;
        });
      } on ApiException {
        if (!mounted) return;
        setState(() => _searching = false);
      }
    });
  }

  Future<void> _openCreatePatient() async {
    final patient = await Navigator.of(context).push<Patient>(
      MaterialPageRoute(builder: (context) => const CreatePatientScreen()),
    );

    if (patient == null || !mounted) return;

    setState(() {
      _selectedPatient = patient;
      _searchResults = [];
      _searchController.clear();
    });
  }

  Future<void> _ouvrirDossier() async {
    final patient = _selectedPatient;
    if (patient == null) return;

    setState(() => _isOpeningDossier = true);

    try {
      final dossier = await DossierService.instance.create(
        patientId: patient.id,
        motif: _motifController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _isOpeningDossier = false;
        _selectedPatient = null;
        _motifController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Dossier ouvert pour ${patient.nom} ${patient.prenom}.'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Constantes',
            onPressed: () => _openConstantesDialog(dossier),
          ),
        ),
      );

      _loadRecentDossiers();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isOpeningDossier = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _openConstantesDialog(Dossier dossier) async {
    final tempController = TextEditingController();
    final tensionSysController = TextEditingController();
    final tensionDiaController = TextEditingController();
    final poulsController = TextEditingController();
    final poidsController = TextEditingController();
    final tailleController = TextEditingController();
    final satController = TextEditingController();
    bool isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Constantes — ${dossier.patient.nom} ${dossier.patient.prenom}'),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: tempController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Température (°C)'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: poulsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Pouls'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: tensionSysController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Tension sys.'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: tensionDiaController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Tension dia.'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: poidsController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Poids (kg)'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: tailleController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'Taille (cm)'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: satController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Saturation O2 (%)'),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        setDialogState(() => isSaving = true);
                        try {
                          await ConstantesService.instance.create(
                            dossier.id,
                            temperature: double.tryParse(tempController.text),
                            tensionSystolique: int.tryParse(tensionSysController.text),
                            tensionDiastolique: int.tryParse(tensionDiaController.text),
                            pouls: int.tryParse(poulsController.text),
                            poids: double.tryParse(poidsController.text),
                            taille: double.tryParse(tailleController.text),
                            saturationO2: int.tryParse(satController.text),
                          );
                          if (context.mounted) Navigator.pop(context);
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
                    : const Text('Enregistrer'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  const Text(
                    'Accueil des patients',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Recherchez un patient existant ou créez un dossier, puis ouvrez son dossier de prise en charge.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 24),
                  StatCard(
                    title: 'Dossiers ouverts',
                    value: _loadingRecent ? '…' : '${_recentDossiers.length}',
                    icon: Icons.folder_open_outlined,
                    subtitle: 'En attente de paiement ou de soins',
                  ),
                  const SizedBox(height: 24),
                  _buildSearchCard(),
                  const SizedBox(height: 24),
                  _buildRecentList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
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
            'Enregistrer une arrivée',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedPatient == null) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un patient (nom, n° dossier)...',
                      prefixIcon: _searching
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : const Icon(Icons.search, size: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _openCreatePatient,
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Nouveau patient'),
                ),
              ],
            ),
            if (_searchResults.isNotEmpty) ...[
              const SizedBox(height: 12),
              ..._searchResults.map(
                (patient) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person_outline),
                  title: Text('${patient.nom} ${patient.prenom}'),
                  subtitle: Text(patient.numeroDossier),
                  trailing: TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedPatient = patient;
                        _searchResults = [];
                        _searchController.clear();
                      });
                    },
                    child: const Text('Sélectionner'),
                  ),
                ),
              ),
            ],
          ] else ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${_selectedPatient!.nom} ${_selectedPatient!.prenom} — ${_selectedPatient!.numeroDossier}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _selectedPatient = null),
                    child: const Text('Changer'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _motifController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Motif de la visite (optionnel)',
                hintText: 'Ex. Consultation générale',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isOpeningDossier ? null : _ouvrirDossier,
                icon: _isOpeningDossier
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.how_to_reg_outlined),
                label: Text(_isOpeningDossier ? 'Ouverture...' : 'Ouvrir le dossier'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentList() {
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
            'Dossiers ouverts en attente',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          if (_loadingRecent)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_recentDossiers.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Aucun dossier ouvert pour le moment.',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            )
          else
            ..._recentDossiers.map(_buildDossierRow),
        ],
      ),
    );
  }

  Widget _buildDossierRow(Dossier dossier) {
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
                  '${dossier.patient.nom} ${dossier.patient.prenom}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  dossier.motif?.isNotEmpty == true ? dossier.motif! : 'Sans motif renseigné',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              dossier.patient.numeroDossier,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ),
          StatusPill(label: statusLabel(dossier.statut), color: statusColor(dossier.statut)),
        ],
      ),
    );
  }
}
