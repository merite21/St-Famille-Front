import 'package:flutter/material.dart';

import '../../models/garde.dart';
import '../../models/planning_entry.dart';
import '../../models/utilisateur.dart';
import '../../services/api_exception.dart';
import '../../services/garde_service.dart';
import '../../services/planning_service.dart';
import '../../services/user_service.dart';
import '../../widgets/module_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_pill.dart';

const List<String> _typesGarde = ['jour', 'nuit', '24h'];

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  List<PlanningEntry> _plannings = [];
  List<Garde> _gardes = [];
  List<Utilisateur> _users = [];
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
        PlanningService.instance.list(),
        GardeService.instance.list(),
        UserService.instance.list(),
      ]);

      if (!mounted) return;

      setState(() {
        _plannings = results[0] as List<PlanningEntry>;
        _gardes = results[1] as List<Garde>;
        _users = results[2] as List<Utilisateur>;
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

  Future<void> _openCreatePlanningDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => _PlanningDialog(users: _users),
    );
    if (created == true) _load();
  }

  Future<void> _openCreateGardeDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => _GardeDialog(users: _users),
    );
    if (created == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final gardesAujourdHui = _gardes.where((g) {
      return g.dateGarde.year == now.year &&
          g.dateGarde.month == now.month &&
          g.dateGarde.day == now.day;
    }).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          const ModuleHeader(title: 'Planning'),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorState()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Planning du personnel',
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Plannings de service et gardes du personnel médical et infirmier.',
                              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: StatCard(
                                    title: 'Plannings',
                                    value: '${_plannings.length}',
                                    icon: Icons.calendar_month_outlined,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: StatCard(
                                    title: 'Gardes aujourd’hui',
                                    value: '$gardesAujourdHui',
                                    icon: Icons.nights_stay_outlined,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildPlanningsCard(),
                            const SizedBox(height: 24),
                            _buildGardesCard(),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Color(0xFFDC2626)),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanningsCard() {
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
                'Plannings de service',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _openCreatePlanningDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nouveau'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_plannings.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Aucun planning enregistré.',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            )
          else
            ..._plannings.map(
              (p) => Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
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
                            p.userNom ?? 'Utilisateur #${p.userId}',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            p.service ?? 'Service non renseigné',
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${_formatDateTime(p.dateDebut)} → ${_formatDateTime(p.dateFin)}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGardesCard() {
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
                'Gardes',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _openCreateGardeDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nouvelle'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_gardes.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Aucune garde enregistrée.',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            )
          else
            ..._gardes.map(
              (g) => Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        g.userNom ?? 'Utilisateur #${g.userId}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${_formatDate(g.dateGarde)} — ${g.typeGarde}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ),
                    StatusPill(label: statusLabel(g.statut), color: statusColor(g.statut)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }
}

class _PlanningDialog extends StatefulWidget {
  final List<Utilisateur> users;

  const _PlanningDialog({required this.users});

  @override
  State<_PlanningDialog> createState() => _PlanningDialogState();
}

class _PlanningDialogState extends State<_PlanningDialog> {
  final _serviceController = TextEditingController();
  Utilisateur? _user;
  DateTime? _dateDebut;
  DateTime? _dateFin;
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _serviceController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDateTime(DateTime? initial) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: initial != null ? TimeOfDay.fromDateTime(initial) : TimeOfDay.now(),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year} $hour:$minute';
  }

  Future<void> _save() async {
    if (_user == null || _dateDebut == null || _dateFin == null) {
      setState(() => _error = 'Veuillez renseigner tous les champs.');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await PlanningService.instance.create(
        userId: _user!.id,
        dateDebut: _dateDebut!,
        dateFin: _dateFin!,
        service: _serviceController.text.trim(),
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
      title: const Text('Nouveau planning'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12)),
              const SizedBox(height: 8),
            ],
            DropdownButtonFormField<Utilisateur>(
              value: _user,
              isExpanded: true,
              decoration: const InputDecoration(hintText: 'Membre du personnel'),
              items: widget.users
                  .map((u) => DropdownMenuItem(value: u, child: Text(u.nomComplet)))
                  .toList(),
              onChanged: (value) => setState(() => _user = value),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _serviceController,
              decoration: const InputDecoration(labelText: 'Service (optionnel)'),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final picked = await _pickDateTime(_dateDebut);
                if (picked != null) setState(() => _dateDebut = picked);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Début'),
                child: Text(_dateDebut == null ? 'Sélectionner' : _formatDateTime(_dateDebut!)),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final picked = await _pickDateTime(_dateFin);
                if (picked != null) setState(() => _dateFin = picked);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Fin'),
                child: Text(_dateFin == null ? 'Sélectionner' : _formatDateTime(_dateFin!)),
              ),
            ),
          ],
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
              : const Text('Enregistrer'),
        ),
      ],
    );
  }
}

class _GardeDialog extends StatefulWidget {
  final List<Utilisateur> users;

  const _GardeDialog({required this.users});

  @override
  State<_GardeDialog> createState() => _GardeDialogState();
}

class _GardeDialogState extends State<_GardeDialog> {
  Utilisateur? _user;
  DateTime? _date;
  String _typeGarde = 'jour';
  bool _isSaving = false;
  String? _error;

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _save() async {
    if (_user == null || _date == null) {
      setState(() => _error = 'Veuillez renseigner tous les champs.');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      await GardeService.instance.create(
        userId: _user!.id,
        dateGarde: _date!,
        typeGarde: _typeGarde,
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
      title: const Text('Nouvelle garde'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 12)),
              const SizedBox(height: 8),
            ],
            DropdownButtonFormField<Utilisateur>(
              value: _user,
              isExpanded: true,
              decoration: const InputDecoration(hintText: 'Membre du personnel'),
              items: widget.users
                  .map((u) => DropdownMenuItem(value: u, child: Text(u.nomComplet)))
                  .toList(),
              onChanged: (value) => setState(() => _user = value),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date ?? now,
                  firstDate: now.subtract(const Duration(days: 1)),
                  lastDate: now.add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _date = picked);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date de garde'),
                child: Text(_date == null ? 'Sélectionner' : _formatDate(_date!)),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _typeGarde,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Type de garde'),
              items: _typesGarde
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (value) => setState(() => _typeGarde = value!),
            ),
          ],
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
              : const Text('Enregistrer'),
        ),
      ],
    );
  }
}
