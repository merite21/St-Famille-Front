import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sainte_famille_front/main.dart';

void main() {
  testWidgets('Affiche l\'écran de connexion au démarrage', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SainteFamilleApp());

    expect(find.text('Bienvenue'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
  });

  testWidgets('Affiche une erreur si les champs sont vides', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SainteFamilleApp());

    await tester.tap(find.text('Se connecter'));
    await tester.pump();

    expect(find.text('Veuillez saisir votre identifiant'), findsOneWidget);
    expect(find.text('Veuillez saisir votre mot de passe'), findsOneWidget);
  });
}
