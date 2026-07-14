import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agile_sprint_sim_mobile/main.dart';

void main() {
  testWidgets('App compiles and runs smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AgileSimMobileApp()));
    expect(find.byType(AgileSimMobileApp), findsOneWidget);
  });
}
