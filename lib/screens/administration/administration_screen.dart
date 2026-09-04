import 'package:flutter/material.dart';

import '../../models/utilisateur.dart';
import '../../widgets/module_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_pill.dart';

const List<String> _roles = [
  'Médecin',
  'Infirmier(ère)',
  'Réceptionniste',
  'Comptable',
  'Administrateur',
];

class AdministrationScreen extends StatefulWidget {
  const AdministrationScreen({super.key});

  @override
  State<AdministrationScreen> createState() => _AdministrationScreenState();
}

class _AdministrationScreenState extends State<AdministrationScreen> {
  final List<Utilisateur> _utilisateurs = [
    const Utilisateur(
      id: 'USR-0001',
      nom: 'ABIALA',
      prenom: 'Marcelline',
      role: 'Administrateur',
      email: 'm.abiala@saintefamille.bj',
      telephone: '97 11 22 33',
      statut: 'Actif',
    ),
    const Utilisateur(
      id: 'USR-0002',
      nom: 'KONE',
      prenom: 'Fatou',
      role: 'Médecin',
      email: 'f.kone@saintefamille.bj',
      telephone: '96 22 33 44',
      statut: 'Actif',
    ),
    const Utilisateur(
      id: 'USR-0003',
      nom: 'DOSSOU',
      prenom: 'Chantal',
      role: 'Infirmier(ère)',
      email: 'c.dossou@saintefamille.bj',
      telephone: '95 33 44 55',
      statut: 'Actif',
    ),
  ];

  Future<void> _openCreateDialog() async {
    final created = await showDialog<Utilisateur>(
      context: context,
      builder: (context) => const _UtilisateurDialog(),
    );

    if (created != null && mounted) {
      setState(() {
        _utilisateurs.insert(0, created);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final actifs = _utilisateurs.where((u) => u.statut == 'Actif').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          const ModuleHeader(title: 'Administration'),
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
                              'Gestion du personnel',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Gérez les comptes et les rôles du personnel de l’établissement.',
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
                        icon: const Icon(Icons.person_add_alt_1),
                        label: const Text('Nouvel utilisateur'),
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
                          title: 'Total utilisateurs',
                          value: '${_utilisateurs.length}',
                          icon: Icons.people_outline,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: 'Comptes actifs',
                          value: '$actifs',
                          icon: Icons.verified_user_outlined,
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
            'Personnel enregistré',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          if (_utilisateurs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(
                  'Aucun utilisateur enregistré pour le moment.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            ..._utilisateurs.map(_buildRow),
        ],
      ),
    );
  }

  Widget _buildRow(Utilisateur utilisateur) {
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
                  '${utilisateur.nom} ${utilisateur.prenom}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  utilisateur.email,
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
              utilisateur.role,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ),
          Expanded(
            child: Text(
              utilisateur.telephone,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ),
          StatusPill(
            label: utilisateur.statut,
            color: statusColor(utilisateur.statut),
          ),
        ],
      ),
    );
  }
}

class _UtilisateurDialog extends StatefulWidget {
  const _UtilisateurDialog();

  @override
  State<_UtilisateurDialog> createState() => _UtilisateurDialogState();
}

class _UtilisateurDialogState extends State<_UtilisateurDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();

  String? _role;
  bool _isSaving = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvel utilisateur'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nom',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nomController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  hintText: 'Ex. AFFOGBOLO',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Ce champ est obligatoire'
                    : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Prénom',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _prenomController,
                decoration: const InputDecoration(
                  hintText: 'Ex. Mérite',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Ce champ est obligatoire'
                    : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Rôle',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _role,
                isExpanded: true,
                decoration: const InputDecoration(
                  hintText: 'Sélectionner un rôle',
                  prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                ),
                items: _roles
                    .map(
                      (role) => DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _role = value),
                validator: (value) =>
                    value == null ? 'Veuillez sélectionner un rôle' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Email',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'exemple@saintefamille.bj',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty) {
                    return 'Ce champ est obligatoire';
                  }
                  if (!email.contains('@') || !email.contains('.')) {
                    return 'Veuillez saisir un email valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Téléphone',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _telephoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: 'Ex. 97 00 00 00',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Ce champ est obligatoire'
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

    final utilisateur = Utilisateur(
      id: 'USR-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      nom: _nomController.text.trim().toUpperCase(),
      prenom: _prenomController.text.trim(),
      role: _role!,
      email: _emailController.text.trim(),
      telephone: _telephoneController.text.trim(),
      statut: 'Actif',
    );

    if (!mounted) return;

    Navigator.pop(context, utilisateur);
  }
}
