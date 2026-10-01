import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nse_ai_terminal/final_terminal_design.dart';

void main(){
  testWidgets('login screen exposes editable API key field', (tester) async {
    await tester.pumpWidget(const FinalTerminalDesign());
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2. Login / Authentication'));
    await tester.pumpAndSettle();
    expect(find.text('Terminal API Key'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'CONNECT'), findsOneWidget);
    expect(find.byIcon(Icons.visibility), findsOneWidget);
    final fields=find.byType(TextField);
    expect(fields, findsNWidgets(4));
  });

  testWidgets('Home page shows AI explanation notification for tapped button', (tester) async {
    await tester.pumpWidget(const FinalTerminalDesign());
    await tester.pumpAndSettle();

    expect(find.text('AI • Home page'), findsNothing);
    await tester.tap(find.text('Option Chain'));
    await tester.pump();

    expect(find.text('AI • Home page'), findsOneWidget);
    expect(find.textContaining('Option Chain'), findsOneWidget);
    expect(find.textContaining('option-chain'), findsOneWidget);
  });
}