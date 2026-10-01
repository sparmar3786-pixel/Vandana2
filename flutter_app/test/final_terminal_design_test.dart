import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nse_ai_terminal/final_terminal_design.dart';

void main(){
  testWidgets('login screen exposes backend URL and separate API keys', (tester) async {
    await tester.pumpWidget(const FinalTerminalDesign());
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    await tester.tap(find.text('2. Login / Authentication'));
    await tester.pumpAndSettle();

    expect(find.text('Backend URL'), findsOneWidget);
    expect(find.text('https://nse-algo-backend-production.up.railway.app'), findsOneWidget);
    expect(find.text('Terminal API Key'), findsOneWidget);
    expect(find.text('Angel One API Key'), findsOneWidget);
    expect(find.text('Backend URL'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'CONNECT'), findsOneWidget);
    expect(find.byIcon(Icons.visibility), findsNWidgets(2));
    expect(find.byType(TextField), findsNWidgets(6));
  });

  testWidgets('Home page shows AI explanation notification for tapped button', (tester) async {
    await tester.pumpWidget(const FinalTerminalDesign());
    await tester.pumpAndSettle();

    // The real app starts on Splash / Launch, then enters Home.
    expect(find.text('GET STARTED'), findsOneWidget);
    await tester.tap(find.text('GET STARTED'));
    await tester.pumpAndSettle();

    expect(find.text('AI • Home page'), findsNothing);
    final optionChain = find.text('Option Chain');
    await tester.ensureVisible(optionChain);
    await tester.pumpAndSettle();
    await tester.tap(optionChain);
    await tester.pump();

    expect(find.text('AI • Home page'), findsOneWidget);
    expect(find.textContaining('CE/PE strike'), findsOneWidget);
    expect(find.text('Only this Home page • no navigation'), findsOneWidget);
  });
}