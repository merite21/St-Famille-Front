import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/patient.dart';

class CreatePatientScreen extends StatefulWidget {
  const CreatePatientScreen({super.key});

  @override
  State<CreatePatientScreen> createState() => _CreatePatientScreenState();
}

class _CreatePatientScreenState extends State<CreatePatientScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _adresseController = TextEditingController();
  final _contactNomController = TextEditingController();
  final _contactTelephoneController = TextEditingController();

  DateTime? _dateNaissance;
  String? _sexe;
  String? _lienContact;

  bool _isSaving = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    _contactNomController.dispose();
    _contactTelephoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDateNaissance() async {
    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(
        now.year - 25,
        now.month,
        now.day,
      ),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Sélectionner la date de naissance',
      cancelText: 'Annuler',
      confirmText: 'Valider',
    );

    if (selectedDate != null) {
      setState(() {
        _dateNaissance = selectedDate;
      });
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();

    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month &&
            today.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  String _generatePatientId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    return 'SF-${timestamp.toString().substring(7)}';
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_dateNaissance == null) {
      _showMessage(
        'Veuillez sélectionner la date de naissance.',
        isError: true,
      );
      return;
    }

    if (_sexe == null) {
      _showMessage(
        'Veuillez sélectionner le sexe.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Simulation temporaire.
    // Cette partie sera remplacée par l'appel à l'API REST PHP.
    await Future.delayed(const Duration(seconds: 1));

    final patient = Patient(
      id: _generatePatientId(),
      nom: _nomController.text.trim().toUpperCase(),
      prenom: _prenomController.text.trim(),
      sexe: _sexe!,
      age: _calculateAge(_dateNaissance!),
      telephone: _telephoneController.text.trim(),
      statut: 'Nouveau',
    );

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    Navigator.pop(context, patient);
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isError ? const Color(0xFFDC2626) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1100,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _buildBreadcrumb(),
                        const SizedBox(height: 22),
                        _buildPageTitle(),
                        const SizedBox(height: 24),
                        _buildPersonalInformation(),
                        const SizedBox(height: 20),
                        _buildContactInformation(),
                        const SizedBox(height: 24),
                        _buildActions(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
            'Nouveau patient',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_outlined,
            ),
          ),
          const SizedBox(width: 10),
          const CircleAvatar(
            radius: 19,
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              'MA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb() {
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
          'Nouveau patient',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildPageTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Créer un dossier patient',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Renseignez les informations nécessaires à la création du dossier.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInformation() {
    return _buildSectionCard(
      title: 'Informations personnelles',
      subtitle: 'Informations d’identification du patient',
      icon: Icons.person_outline,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _nomController,
                  label: 'Nom',
                  hint: 'Ex. AFFOGBOLO',
                  icon: Icons.badge_outlined,
                  required: true,
                  textCapitalization:
                      TextCapitalization.characters,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildTextField(
                  controller: _prenomController,
                  label: 'Prénom',
                  hint: 'Ex. Mérite',
                  icon: Icons.person_outline,
                  required: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDateField(),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildSexeField(),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _telephoneController,
                  label: 'Téléphone',
                  hint: 'Ex. 97 00 00 00',
                  icon: Icons.phone_outlined,
                  required: true,
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildTextField(
                  controller: _adresseController,
                  label: 'Adresse',
                  hint: 'Adresse du patient',
                  icon: Icons.location_on_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactInformation() {
    return _buildSectionCard(
      title: 'Personne à contacter',
      subtitle:
          'Personne à joindre en cas de besoin',
      icon: Icons.contact_phone_outlined,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _contactNomController,
                  label: 'Nom du contact',
                  hint: 'Nom et prénom',
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildTextField(
                  controller: _contactTelephoneController,
                  label: 'Téléphone du contact',
                  hint: 'Numéro de téléphone',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildLienContactField(),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(
          'Date de naissance',
          required: true,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDateNaissance,
          borderRadius: BorderRadius.circular(10),
          child: InputDecorator(
            decoration: const InputDecoration(
              hintText: 'JJ/MM/AAAA',
              prefixIcon: Icon(
                Icons.calendar_today_outlined,
              ),
            ),
            child: Text(
              _dateNaissance == null
                  ? 'Sélectionner une date'
                  : _formatDate(_dateNaissance!),
              style: TextStyle(
                fontSize: 14,
                color: _dateNaissance == null
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF334155),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSexeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(
          'Sexe',
          required: true,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _sexe,
          decoration: const InputDecoration(
            hintText: 'Sélectionner',
            prefixIcon: Icon(
              Icons.wc_outlined,
            ),
          ),
          items: const [
            DropdownMenuItem(
              value: 'Homme',
              child: Text('Homme'),
            ),
            DropdownMenuItem(
              value: 'Femme',
              child: Text('Femme'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _sexe = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez sélectionner le sexe';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLienContactField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Lien avec le patient'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _lienContact,
          decoration: const InputDecoration(
            hintText: 'Sélectionner',
            prefixIcon: Icon(
              Icons.family_restroom_outlined,
            ),
          ),
          items: const [
            DropdownMenuItem(
              value: 'Parent',
              child: Text('Parent'),
            ),
            DropdownMenuItem(
              value: 'Conjoint(e)',
              child: Text('Conjoint(e)'),
            ),
            DropdownMenuItem(
              value: 'Enfant',
              child: Text('Enfant'),
            ),
            DropdownMenuItem(
              value: 'Frère / Sœur',
              child: Text('Frère / Sœur'),
            ),
            DropdownMenuItem(
              value: 'Autre',
              child: Text('Autre'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _lienContact = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization =
        TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(
          label,
          required: required,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
          ),
          validator: required
              ? (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Ce champ est obligatoire';
                  }

                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildLabel(
    String label, {
    bool required = false,
  }) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
        children: [
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: Color(0xFFDC2626),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor
                      .withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: _isSaving
              ? null
              : () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(120, 50),
          ),
          child: const Text('Annuler'),
        ),
        const SizedBox(width: 14),
        ElevatedButton.icon(
          onPressed: _isSaving ? null : _savePatient,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(
                  Icons.person_add_alt_1,
                  size: 19,
                ),
          label: Text(
            _isSaving
                ? 'Enregistrement...'
                : 'Créer le dossier',
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(190, 50),
          ),
        ),
      ],
    );
  }
}