import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/dossier.dart';
import '../../models/paiement.dart';
import '../../models/patient.dart';
import '../../models/prestation.dart';
import '../../services/api_exception.dart';
import '../../services/dossier_service.dart';
import '../../services/file_attente_service.dart';
import '../../services/paiement_service.dart';
import '../../services/patient_service.dart';
import '../../services/prestation_service.dart';
import '../../widgets/module_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_pill.dart';

class PaiementsScreen extends StatefulWidget {
  const PaiementsScreen({super.key});

  @override
  State<PaiementsScreen> createState() => _PaiementsScreenState();
}

class _PaiementsScreenState extends State<PaiementsScreen> {
  List<Paiement> _paiements = [];
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
      final paiements = await PaiementService.instance.list();
      if (!mounted) return;
      setState(() {
        _paiements = paiements;
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
      builder: (context) => const _NouveauPaiementDialog(),
    );

    if (created == true) {
      _load();
    }
  }

  Future<void> _confirmer(Paiement paiement) async {
    Paiement confirme;
    try {
      confirme = await PaiementService.instance.confirmer(paiement.id);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }

    _load();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Paiement confirmé.'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Envoyer en file d’attente',
          onPressed: () => _envoyerEnFileAttente(confirme),
        ),
      ),
    );
  }

  Future<void> _envoyerEnFileAttente(Paiement paiement) async {
    try {
      await FileAttenteService.instance.create(dossierId: paiement.dossierId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Patient envoyé en file d’attente.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _paiements
        .where((p) => p.statut == 'confirme')
        .fold<double>(0, (sum, p) => sum + p.montantFcfa);
    final enAttente = _paiements.where((p) => p.statut == 'en_attente').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          const ModuleHeader(title: 'Paiements'),
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
                              'Gestion des paiements',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Enregistrez et confirmez les paiements des patients.',
                              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _openCreateDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Nouveau paiement'),
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
                          title: 'Total encaissé',
                          value: '${total.toStringAsFixed(0)} FCFA',
                          icon: Icons.payments_outlined,
                        ),
                      ),
                      const SizedBox(width: 16),
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
                          title: 'Transactions',
                          value: '${_paiements.length}',
                          icon: Icons.receipt_long_outlined,
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
            'Historique des paiements',
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
          else if (_paiements.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  'Aucun paiement enregistré pour le moment.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            ..._paiements.map(_buildRow),
        ],
      ),
    );
  }

  Widget _buildRow(Paiement paiement) {
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
                  paiement.patientNom ?? 'Dossier #${paiement.dossierId}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  paiement.prestationLibelle ?? '',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              '${paiement.montantFcfa.toStringAsFixed(0)} FCFA',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          StatusPill(label: statusLabel(paiement.statut), color: statusColor(paiement.statut)),
          const SizedBox(width: 12),
          SizedBox(
            width: 90,
            child: paiement.statut == 'en_attente'
                ? TextButton(
                    onPressed: () => _confirmer(paiement),
                    child: const Text('Confirmer'),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

class _NouveauPaiementDialog extends StatefulWidget {
  const _NouveauPaiementDialog();

  @override
  State<_NouveauPaiementDialog> createState() => _NouveauPaiementDialogState();
}

class _NouveauPaiementDialogState extends State<_NouveauPaiementDialog> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  List<Patient> _patientResults = [];
  Patient? _selectedPatient;

  List<Dossier> _dossiers = [];
  Dossier? _selectedDossier;
  bool _loadingDossiers = false;

  List<Prestation> _prestations = [];
  Prestation? _selectedPrestation;

  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPrestations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadPrestations() async {
    try {
      final prestations = await PrestationService.instance.list();
      if (!mounted) return;
      setState(() => _prestations = prestations);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() => _patientResults = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      final results = await PatientService.instance.search(q: value);
      if (!mounted) return;
      setState(() => _patientResults = results);
    });
  }

  Future<void> _selectPatient(Patient patient) async {
    setState(() {
      _selectedPatient = patient;
      _patientResults = [];
      _searchController.clear();
      _loadingDossiers = true;
      _selectedDossier = null;
    });

    try {
      final dossiers = await DossierService.instance.list(
        patientId: patient.id,
        statut: 'ouvert',
      );
      if (!mounted) return;
      setState(() {
        _dossiers = dossiers;
        _loadingDossiers = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loadingDossiers = false;
      });
    }
  }

  Future<void> _save() async {
    if (_selectedDossier == null || _selectedPrestation == null) return;

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await PaiementService.instance.create(
        dossierId: _selectedDossier!.id,
        prestationId: _selectedPrestation!.id,
      );
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
      title: const Text('Nouveau paiement'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null) ...[
                Text(_error!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12)),
                const SizedBox(height: 8),
              ],
              const Text('Patient', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              if (_selectedPatient == null) ...[
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: const InputDecoration(
                    hintText: 'Rechercher un patient...',
                    prefixIcon: Icon(Icons.search, size: 20),
                  ),
                ),
                ..._patientResults.map(
                  (p) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text('${p.nom} ${p.prenom}'),
                    subtitle: Text(p.numeroDossier),
                    onTap: () => _selectPatient(p),
                  ),
                ),
              ] else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_selectedPatient!.nom} ${_selectedPatient!.prenom}',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() {
                          _selectedPatient = null;
                          _dossiers = [];
                          _selectedDossier = null;
                        }),
                        child: const Text('Changer'),
                      ),
                    ],
                  ),
                ),
              if (_selectedPatient != null) ...[
                const SizedBox(height: 16),
                const Text('Dossier', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                if (_loadingDossiers)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(),
                  )
                else if (_dossiers.isEmpty)
                  const Text(
                    'Aucun dossier ouvert pour ce patient. Ouvrez-en un depuis la Réception.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  )
                else
                  DropdownButtonFormField<Dossier>(
                    value: _selectedDossier,
                    isExpanded: true,
                    decoration: const InputDecoration(hintText: 'Sélectionner un dossier'),
                    items: _dossiers
                        .map(
                          (d) => DropdownMenuItem(
                            value: d,
                            child: Text(
                              d.motif?.isNotEmpty == true ? d.motif! : 'Dossier #${d.id}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _selectedDossier = value),
                  ),
              ],
              const SizedBox(height: 16),
              const Text('Prestation', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<Prestation>(
                value: _selectedPrestation,
                isExpanded: true,
                decoration: const InputDecoration(hintText: 'Sélectionner une prestation'),
                items: _prestations
                    .map(
                      (p) => DropdownMenuItem(
                        value: p,
                        child: Text(
                          '${p.libelle} — ${p.montantFcfa.toStringAsFixed(0)} FCFA',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedPrestation = value),
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
          onPressed: (_isSaving || _selectedDossier == null || _selectedPrestation == null)
              ? null
              : _save,
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
