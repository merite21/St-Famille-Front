import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/dossier.dart';
import '../../models/patient.dart';
import '../../services/api_exception.dart';
import '../../services/dossier_service.dart';
import '../../services/patient_service.dart';
import '../../widgets/status_pill.dart';

class PatientDetailScreen extends StatefulWidget {
  final int patientId;

  const PatientDetailScreen({
    super.key,
    required this.patientId,
  });

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  Patient? _patient;
  List<Dossier> _dossiers = [];
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
        PatientService.instance.getById(widget.patientId),
        DossierService.instance.list(patientId: widget.patientId),
      ]);

      if (!mounted) return;

      setState(() {
        _patient = results[0] as Patient;
        _dossiers = results[1] as List<Dossier>;
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

  Future<void> _openNewDossierDialog() async {
    final motifController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    final created = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Ouvrir un nouveau dossier'),
            content: Form(
              key: formKey,
              child: SizedBox(
                width: 380,
                child: TextFormField(
                  controller: motifController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Motif (optionnel)',
                    hintText: 'Ex. Consultation générale',
                  ),
                ),
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
                          await DossierService.instance.create(
                            patientId: widget.patientId,
                            motif: motifController.text.trim(),
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
                    : const Text('Ouvrir'),
              ),
            ],
          );
        },
      ),
    );

    if (created == true) {
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(context),
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
                            _buildBreadcrumb(context),
                            const SizedBox(height: 22),
                            _buildPatientHeader(),
                            const SizedBox(height: 24),
                            _buildInformationSection(),
                            const SizedBox(height: 20),
                            _buildContactSection(),
                            const SizedBox(height: 20),
                            _buildDossiersSection(),
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
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: const Text('Réessayer')),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Retour',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 8),
          const Text(
            'Dossier patient',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          child: const Text(
            'Patients',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            Icons.chevron_right,
            size: 17,
            color: Color(0xFF94A3B8),
          ),
        ),
        const Text(
          'Dossier patient',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildPatientHeader() {
    final patient = _patient!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.10),
            child: Text(
              _initial(patient.prenom),
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${patient.nom} ${patient.prenom}',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 18,
                  runSpacing: 6,
                  children: [
                    _buildSmallInfo(Icons.badge_outlined, patient.numeroDossier),
                    _buildSmallInfo(
                      Icons.person_outline,
                      patient.age == null
                          ? patient.sexeLabel
                          : '${patient.sexeLabel} • ${patient.age} ans',
                    ),
                    _buildSmallInfo(
                      Icons.phone_outlined,
                      patient.telephone ?? 'Non renseigné',
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _openNewDossierDialog,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Nouveau dossier'),
          ),
        ],
      ),
    );
  }

  String _initial(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? '?' : trimmed.substring(0, 1).toUpperCase();
  }

  Widget _buildSmallInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF64748B),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildInformationSection() {
    final patient = _patient!;

    return _buildSectionCard(
      title: 'Informations administratives',
      icon: Icons.person_outline,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildInfoItem('Nom', patient.nom)),
              Expanded(child: _buildInfoItem('Prénom', patient.prenom)),
              Expanded(child: _buildInfoItem('Sexe', patient.sexeLabel)),
              Expanded(
                child: _buildInfoItem(
                  'Âge',
                  patient.age == null ? 'À renseigner' : '${patient.age} ans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Téléphone',
                  patient.telephone ?? 'À renseigner',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Date de naissance',
                  patient.dateNaissance == null
                      ? 'À renseigner'
                      : _formatDate(patient.dateNaissance!),
                ),
              ),
              Expanded(
                child: _buildInfoItem('Adresse', patient.adresse ?? 'À renseigner'),
              ),
              Expanded(
                child: _buildInfoItem('N° dossier patient', patient.numeroDossier),
              ),
            ],
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

  Widget _buildContactSection() {
    final contact = _patient!.contactUrgence;

    return _buildSectionCard(
      title: 'Personne à contacter',
      icon: Icons.contact_phone_outlined,
      child: (contact == null || contact.isEmpty)
          ? const Text(
              'Aucune personne à contacter renseignée.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            )
          : Text(
              contact,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
    );
  }

  Widget _buildDossiersSection() {
    return _buildSectionCard(
      title: 'Historique des dossiers',
      icon: Icons.history,
      child: _dossiers.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Aucun dossier ouvert pour ce patient.',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
            )
          : Column(
              children: _dossiers.map(_buildDossierRow).toList(),
            ),
    );
  }

  Widget _buildDossierRow(Dossier dossier) {
    final color = statusColor(dossier.statut);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.folder_open_outlined,
              size: 20,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dossier.motif?.isNotEmpty == true ? dossier.motif! : 'Dossier #${dossier.id}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ouvert le ${_formatDate(dossier.ouvertAt)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          StatusPill(label: statusLabel(dossier.statut), color: color),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}
