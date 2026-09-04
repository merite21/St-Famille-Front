import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Badge coloré générique pour représenter un statut (dossier, paiement,
/// file d'attente, soins, garde, personnel...).
class StatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const StatusPill({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Libellé français pour un statut brut renvoyé par l'API (snake_case).
String statusLabel(String status) {
  const labels = {
    // Dossier
    'ouvert': 'Ouvert',
    'en_cours': 'En cours',
    'cloture': 'Clôturé',
    // Paiement
    'en_attente': 'En attente',
    'confirme': 'Confirmé',
    'annule': 'Annulé',
    'annulee': 'Annulée',
    'rembourse': 'Remboursé',
    // File d'attente / soins
    'appele': 'Appelé',
    'en_consultation': 'En consultation',
    'termine': 'Terminé',
    'attribue': 'Attribué',
    'reporte': 'Reporté',
    'patient_absent': 'Patient absent',
    // Gardes
    'planifiee': 'Planifiée',
    'confirmee': 'Confirmée',
    'remplacee': 'Remplacée',
    // Orientation consultation
    'sans_soins': 'Sans soins',
    'avec_soins': 'Avec soins',
    'autre': 'Autre',
    // Personnel
    'actif': 'Actif',
    'inactif': 'Inactif',
  };

  return labels[status] ??
      status
          .split('_')
          .map((word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}')
          .join(' ');
}

/// Palette de couleurs partagée pour les statuts bruts renvoyés par
/// l'API (snake_case) — file d'attente, paiements, soins, gardes,
/// dossiers, personnel...
Color statusColor(String status) {
  switch (status) {
    case 'actif':
    case 'confirme':
    case 'confirmee':
    case 'termine':
    case 'cloture':
    case 'avec_soins':
      return const Color(0xFF15803D);
    case 'attribue':
    case 'en_consultation':
    case 'en_cours':
    case 'ouvert':
    case 'planifiee':
      return AppTheme.primaryColor;
    case 'en_attente':
    case 'appele':
    case 'reporte':
      return const Color(0xFFF59E0B);
    case 'inactif':
    case 'annule':
    case 'annulee':
    case 'remplacee':
    case 'patient_absent':
    case 'rembourse':
      return const Color(0xFF94A3B8);
    default:
      return const Color(0xFF475569);
  }
}
