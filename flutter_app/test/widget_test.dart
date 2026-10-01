import 'package:flutter_test/flutter_test.dart';
import 'package:nse_ai_terminal/main.dart';

void main() {
  testWidgets('renders the NSE-AI-TERMINAL shell', (tester) async {
    await tester.pumpWidget(const AlgoApp());
    expect(find.text('NSE-AI-TERMINAL'), findsWidgets);
    expect(find.text('LIVE'), findsOneWidget);
  });
}
