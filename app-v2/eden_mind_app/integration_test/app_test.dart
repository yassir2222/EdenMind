import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:eden_mind_app/main.dart';
import 'package:eden_mind_app/features/auth/auth_service.dart';
import 'package:provider/provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app starts and loads on Web/Edge', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthService()..init()),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    print('App loaded successfully on Web!');
  });
}
