import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Badge coloré générique pour représenter un statut (patient, paiement,
/// rendez-vous, prise en charge, membre du personnel...).
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

/// Palette de couleurs partagée pour les statuts utilisés dans
/// l'application (file d'attente, paiements, rendez-vous, personnel...).
Color statusColor(String status) {
  switch (status) {
    case 'Actif':
    case 'Payé':
    case 'Confirmé':
    case 'Terminé':
    case 'Terminée':
    case 'Réalisé':
      return const Color(0xFF15803D);
    case 'Nouveau':
    case 'En consultation':
    case 'Programmée':
    case 'Planifié':
      return AppTheme.primaryColor;
    case 'En attente':
      return const Color(0xFFF59E0B);
    case 'Inactif':
    case 'Annulé':
    case 'Annulée':
      return const Color(0xFF94A3B8);
    default:
      return const Color(0xFF475569);
  }
}
