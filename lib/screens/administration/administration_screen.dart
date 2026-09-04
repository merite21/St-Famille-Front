import 'package:flutter/material.dart';

import '../../models/role.dart';
import '../../models/utilisateur.dart';
import '../../services/api_exception.dart';
import '../../services/role_service.dart';
import '../../services/user_service.dart';
import '../../widgets/module_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_pill.dart';

class AdministrationScreen extends StatefulWidget {
  const AdministrationScreen({super.key});

  @override
  State<AdministrationScreen> createState() => _AdministrationScreenState();
}

class _AdministrationScreenState extends State<AdministrationScreen> {
  List<Utilisateur> _users = [];
  List<Role> _roles = [];
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
      final results = await Future.wait([
        UserService.instance.list(),
        RoleService.instance.list(),
      ]);

      if (!mounted) return;

      setState(() {
        _users = results[0] as List<Utilisateur>;
        _roles = results[1] as List<Role>;
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
      builder: (context) => _UtilisateurDialog(roles: _roles),
    );

    if (created == true) _load();
  }

  Future<void> _toggleActif(Utilisateur user) async {
    try {
      await UserService.instance.update(user.id, actif: !user.actif);
      _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final actifs = _users.where((u) => u.actif).length;

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
                              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _roles.isEmpty ? null : _openCreateDialog,
                        icon: const Icon(Icons.person_add_alt_1),
                        label: const Text('Nouvel utilisateur'),
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
                          title: 'Total utilisateurs',
                          value: _loading ? '…' : '${_users.length}',
                          icon: Icons.people_outline,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: 'Comptes actifs',
                          value: _loading ? '…' : '$actifs',
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
          else if (_users.isEmpty)
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
            ..._users.map(_buildRow),
        ],
      ),
    );
  }

  Widget _buildRow(Utilisateur user) {
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
                  user.nomComplet,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  user.matricule,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              roleLabel(user.role),
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ),
          Expanded(
            child: Text(
              user.telephone ?? 'Non renseigné',
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ),
          StatusPill(
            label: user.actif ? 'Actif' : 'Inactif',
            color: statusColor(user.actif ? 'actif' : 'inactif'),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () => _toggleActif(user),
            child: Text(user.actif ? 'Désactiver' : 'Activer'),
          ),
        ],
      ),
    );
  }
}

class _UtilisateurDialog extends StatefulWidget {
  final List<Role> roles;

  const _UtilisateurDialog({required this.roles});

  @override
  State<_UtilisateurDialog> createState() => _UtilisateurDialogState();
}

class _UtilisateurDialogState extends State<_UtilisateurDialog> {
  final _formKey = GlobalKey<FormState>();
  final _matriculeController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();

  Role? _role;
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _matriculeController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_role == null) {
      setState(() => _error = 'Veuillez sélectionner un rôle.');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await UserService.instance.create(
        matricule: _matriculeController.text.trim(),
        nom: _nomController.text.trim().toUpperCase(),
        prenom: _prenomController.text.trim(),
        roleId: _role!.id,
        password: _passwordController.text,
        email: _emailController.text.trim(),
        telephone: _telephoneController.text.trim(),
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
      title: const Text('Nouvel utilisateur'),
      content: SizedBox(
        width: 420,
        child: Form(
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
                TextFormField(
                  controller: _matriculeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Matricule', hintText: 'Ex. MED-002'),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Ce champ est obligatoire' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nomController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Nom'),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Ce champ est obligatoire' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _prenomController,
                  decoration: const InputDecoration(labelText: 'Prénom'),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty) ? 'Ce champ est obligatoire' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Role>(
                  value: _role,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Rôle'),
                  items: widget.roles
                      .map((r) => DropdownMenuItem(value: r, child: Text(r.libelle)))
                      .toList(),
                  onChanged: (value) => setState(() => _role = value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email (optionnel)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telephoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Téléphone (optionnel)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Mot de passe initial'),
                  validator: (value) => (value == null || value.length < 4)
                      ? 'Au moins 4 caractères'
                      : null,
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
          onPressed: _isSaving ? null : _save,
          child: _isSaving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Créer'),
        ),
      ],
    );
  }
}
