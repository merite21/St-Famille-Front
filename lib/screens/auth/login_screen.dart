import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../services/api_exception.dart';
import '../../services/auth_service.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.instance.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Navigation vers le tableau de bord.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const DashboardScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 460,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildLogo(),

                    const SizedBox(height: 32),

                    const Text(
                      'Bienvenue',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Connectez-vous à votre espace professionnel',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF64748B),
                      ),
                    ),

                    const SizedBox(height: 36),

                    const Text(
                      'Matricule',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _usernameController,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'Ex. ADM-001',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Veuillez saisir votre matricule';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Mot de passe',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      decoration: InputDecoration(
                        hintText: 'Votre mot de passe',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Afficher le mot de passe'
                              : 'Masquer le mot de passe',
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez saisir votre mot de passe';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Spacer(),

                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'La récupération du mot de passe sera disponible ultérieurement.',
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'Mot de passe oublié ?',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Se connecter',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    _buildSecurityMessage(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.local_hospital_outlined,
            size: 46,
            color: AppTheme.primaryColor,
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'SAINTE FAMILLE',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: AppTheme.primaryColor,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          'Gestion du parcours patient',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.verified_user_outlined,
          size: 18,
          color: AppTheme.secondaryColor,
        ),
        const SizedBox(width: 8),
        const Flexible(
          child: Text(
            'Accès réservé au personnel autorisé',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }
}