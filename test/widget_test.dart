import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_mind/main.dart';
import 'package:shop_mind/providers/app_provider.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppProvider()),
        ],
        child: const SmartShoppingListApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Not logged in, so the login screen should be shown.
    expect(find.text('ShopMind'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}