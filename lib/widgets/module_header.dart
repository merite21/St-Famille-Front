import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// En-tête commun aux écrans de module : bouton retour, titre,
/// notifications et avatar de l'utilisateur connecté.
class ModuleHeader extends StatelessWidget {
  final String title;
  final bool showBackButton;

  const ModuleHeader({
    super.key,
    required this.title,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        children: [
          if (showBackButton) ...[
            IconButton(
              tooltip: 'Retour',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_outlined),
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
}
