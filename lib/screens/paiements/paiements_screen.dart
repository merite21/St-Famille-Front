import 'package:flutter/material.dart';

import '../../data/patient_directory.dart';
import '../../models/paiement.dart';
import '../../models/patient.dart';
import '../../widgets/module_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_pill.dart';

const List<String> _methodesPaiement = [
  'Espèces',
  'Mobile Money',
  'Carte bancaire',
  'Assurance',
];

class PaiementsScreen extends StatefulWidget {
  const PaiementsScreen({super.key});

  @override
  State<PaiementsScreen> createState() => _PaiementsScreenState();
}

class _PaiementsScreenState extends State<PaiementsScreen> {
  final List<Paiement> _paiements = [];

  Future<void> _openCreateDialog() async {
    final created = await showDialog<Paiement>(
      context: context,
      builder: (context) => const _PaiementDialog(),
    );

    if (created != null && mounted) {
      setState(() {
        _paiements.insert(0, created);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _paiements.fold<double>(0, (sum, p) => sum + p.montant);
    final enAttente =
        _paiements.where((p) => p.statut == 'En attente').length;

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
                              'Enregistrez et suivez les paiements des patients.',
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
                        label: const Text('Nouveau paiement'),
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
                          title: 'Total encaissé',
                          value: '${total.toStringAsFixed(0)} FCFA',
                          icon: Icons.payments_outlined,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: 'Paiements en attente',
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
          if (_paiements.isEmpty)
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
                  '${paiement.patient.nom} ${paiement.patient.prenom}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  paiement.motif,
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
              paiement.methode,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ),
          Expanded(
            child: Text(
              '${paiement.montant.toStringAsFixed(0)} FCFA',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          StatusPill(
            label: paiement.statut,
            color: statusColor(paiement.statut),
          ),
        ],
      ),
    );
  }
}

class _PaiementDialog extends StatefulWidget {
  const _PaiementDialog();

  @override
  State<_PaiementDialog> createState() => _PaiementDialogState();
}

class _PaiementDialogState extends State<_PaiementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _montantController = TextEditingController();
  final _motifController = TextEditingController();

  Patient? _patient;
  String? _methode;
  bool _isSaving = false;

  @override
  void dispose() {
    _montantController.dispose();
    _motifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patients = PatientDirectory.all;

    return AlertDialog(
      title: const Text('Nouveau paiement'),
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
                'Montant (FCFA)',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _montantController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Ex. 5000',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  final montant = double.tryParse(value?.trim() ?? '');
                  if (montant == null || montant <= 0) {
                    return 'Veuillez saisir un montant valide';
                  }
                  return null;
                },
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
                  hintText: 'Ex. Consultation générale',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Ce champ est obligatoire'
                    : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Méthode de paiement',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _methode,
                isExpanded: true,
                decoration: const InputDecoration(
                  hintText: 'Sélectionner une méthode',
                  prefixIcon: Icon(Icons.credit_card_outlined),
                ),
                items: _methodesPaiement
                    .map(
                      (methode) => DropdownMenuItem(
                        value: methode,
                        child: Text(methode),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _methode = value),
                validator: (value) => value == null
                    ? 'Veuillez sélectionner une méthode'
                    : null,
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

    final paiement = Paiement(
      id: 'PAI-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      patient: _patient!,
      montant: double.parse(_montantController.text.trim()),
      methode: _methode!,
      motif: _motifController.text.trim(),
      statut: 'Payé',
      date: DateTime.now(),
    );

    if (!mounted) return;

    Navigator.pop(context, paiement);
  }
}
