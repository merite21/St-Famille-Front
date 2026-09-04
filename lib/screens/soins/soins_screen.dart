import 'package:flutter/material.dart';

import '../../models/attribution_soin.dart';
import '../../models/demande_soin.dart';
import '../../models/salle_soin.dart';
import '../../models/utilisateur.dart';
import '../../services/api_exception.dart';
import '../../services/attribution_soin_service.dart';
import '../../services/demande_soin_service.dart';
import '../../services/salle_soin_service.dart';
import '../../services/soin_service.dart';
import '../../services/user_service.dart';
import '../../widgets/module_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_pill.dart';

class SoinsScreen extends StatefulWidget {
  const SoinsScreen({super.key});

  @override
  State<SoinsScreen> createState() => _SoinsScreenState();
}

class _SoinsScreenState extends State<SoinsScreen> {
  List<DemandeSoin> _demandes = [];
  bool _loading = true;
  String? _error;
  bool _busy = false;

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
      final demandes = await DemandeSoinService.instance.list();
      if (!mounted) return;
      setState(() {
        _demandes = demandes;
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

  Future<void> _attribuer(DemandeSoin demande) async {
    List<Utilisateur> infirmiers;
    List<SalleSoin> salles;
    try {
      final results = await Future.wait([
        UserService.instance.list(),
        SalleSoinService.instance.list(),
      ]);
      infirmiers = (results[0] as List<Utilisateur>)
          .where((u) => u.role == 'infirmier' && u.actif)
          .toList();
      salles = results[1] as List<SalleSoin>;
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }

    if (!mounted) return;

    Utilisateur? selectedInfirmier;
    SalleSoin? selectedSalle;
    bool isSaving = false;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Attribuer — ${demande.patientNom ?? 'Dossier #${demande.dossierId}'}'),
            content: SizedBox(
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<Utilisateur>(
                    value: selectedInfirmier,
                    isExpanded: true,
                    decoration: const InputDecoration(hintText: 'Infirmier(ère)'),
                    items: infirmiers
                        .map((i) => DropdownMenuItem(value: i, child: Text(i.nomComplet)))
                        .toList(),
                    onChanged: (value) => setDialogState(() => selectedInfirmier = value),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<SalleSoin>(
                    value: selectedSalle,
                    isExpanded: true,
                    decoration: const InputDecoration(hintText: 'Salle de soins (optionnel)'),
                    items: salles
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.nom)))
                        .toList(),
                    onChanged: (value) => setDialogState(() => selectedSalle = value),
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
                onPressed: (isSaving || selectedInfirmier == null)
                    ? null
                    : () async {
                        setDialogState(() => isSaving = true);
                        try {
                          await AttributionSoinService.instance.create(
                            demandeSoinId: demande.id,
                            infirmierId: selectedInfirmier!.id,
                            salleSoinId: selectedSalle?.id,
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
                    : const Text('Attribuer'),
              ),
            ],
          );
        },
      ),
    );

    if (ok == true) _load();
  }

  Future<void> _demarrer(DemandeSoin demande) async {
    if (demande.attributionId == null) return;

    setState(() => _busy = true);
    try {
      await AttributionSoinService.instance.updateStatut(demande.attributionId!, 'en_cours');
      _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _realiser(DemandeSoin demande) async {
    if (demande.attributionId == null) return;

    AttributionSoin attribution;
    try {
      attribution = await AttributionSoinService.instance.getById(demande.attributionId!);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }

    if (attribution.soinId == null || !mounted) return;

    final realiseController = TextEditingController();
    final observationsController = TextEditingController();
    final incidentController = TextEditingController();
    bool valide = true;
    bool isSaving = false;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Réaliser le soin — ${demande.patientNom ?? ''}'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: realiseController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Soin réalisé'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: observationsController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Observations (optionnel)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: incidentController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Incident (optionnel)'),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: valide,
                    onChanged: (value) => setDialogState(() => valide = value ?? true),
                    title: const Text('Valider le soin', style: TextStyle(fontSize: 13)),
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
                onPressed: isSaving
                    ? null
                    : () async {
                        setDialogState(() => isSaving = true);
                        try {
                          await SoinService.instance.update(
                            attribution.soinId!,
                            soinRealise: realiseController.text.trim(),
                            observations: observationsController.text.trim(),
                            incident: incidentController.text.trim(),
                            valide: valide,
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
                    : const Text('Enregistrer'),
              ),
            ],
          );
        },
      ),
    );

    if (ok == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final enAttente = _demandes.where((d) => d.statut == 'en_attente').length;
    final enCours = _demandes.where((d) => d.statut == 'attribue' || d.statut == 'en_cours').length;
    final termines = _demandes.where((d) => d.statut == 'termine').length;

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
                  const Text(
                    'Soins infirmiers',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Attribuez les demandes de soins créées par les médecins et suivez leur réalisation.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'En attente d’attribution',
                          value: '$enAttente',
                          icon: Icons.pending_actions_outlined,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: 'En cours',
                          value: '$enCours',
                          icon: Icons.healing_outlined,
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
                'Demandes de soins',
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
            Column(
              children: [
                Text(_error!, style: const TextStyle(fontSize: 13, color: Color(0xFFDC2626))),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: _load, child: const Text('Réessayer')),
              ],
            )
          else if (_demandes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  'Aucune demande de soins pour le moment.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            ..._demandes.map(_buildRow),
        ],
      ),
    );
  }

  Widget _buildRow(DemandeSoin demande) {
    Widget? action;

    if (!_busy) {
      switch (demande.statut) {
        case 'en_attente':
          action = TextButton(
            onPressed: () => _attribuer(demande),
            child: const Text('Attribuer'),
          );
          break;
        case 'attribue':
          action = TextButton(
            onPressed: () => _demarrer(demande),
            child: const Text('Démarrer'),
          );
          break;
        case 'en_cours':
          action = TextButton(
            onPressed: () => _realiser(demande),
            child: const Text('Réaliser'),
          );
          break;
      }
    }

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
                  demande.patientNom ?? 'Dossier #${demande.dossierId}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  demande.typeSoin ?? '',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                ),
              ],
            ),
          ),
          if (demande.priorite == 'urgente')
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.priority_high, size: 16, color: Color(0xFFDC2626)),
            ),
          StatusPill(label: statusLabel(demande.statut), color: statusColor(demande.statut)),
          const SizedBox(width: 12),
          SizedBox(width: 100, child: action),
        ],
      ),
    );
  }
}
