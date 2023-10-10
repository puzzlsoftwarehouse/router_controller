import 'package:example/main.dart';
import 'package:example/pages/first_page.dart';
import 'package:example/pages/second_page.dart';
import 'package:example/pages/three_page.dart';
import 'package:example/router/router_controller.dart';
import 'package:example/router/router_handler.dart';
import 'package:router_controller/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'mock/router_mock.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late RouterController routerController;

  Widget makeTestableWidget() => MaterialApp(
        navigatorKey: navigationApp,
        onGenerateRoute: routerController.router.generator,
      );

  setUp(() {
    routerController = RouterController();

    RouterMock.mock(
      controller: routerController,
      routers: {
        RouterHandler.firstName: Handler(func: (_, __) => const FirstPage()),
        RouterHandler.secondName: Handler(func: (_, __) => const SecondPage()),
        RouterHandler.threeName: Handler(func: (_, __) => const ThreePage()),
      },
    );
  });

  testWidgets("Routes should work correctly with navigation", (tester) async {
    await tester.pumpWidget(makeTestableWidget());
    await tester.pumpAndSettle();

    expect(find.byType(FirstPage), findsOneWidget);
    expect(find.byType(SecondPage), findsNothing);
    expect(find.byType(ThreePage), findsNothing);

    routerController.navigateWithName(nameRouter: RouterHandler.secondName);
    await tester.pumpAndSettle();

    expect(find.byType(FirstPage), findsNothing);
    expect(find.byType(SecondPage), findsOneWidget);
    expect(find.byType(ThreePage), findsNothing);

    routerController.navigateWithName(nameRouter: RouterHandler.threeName);
    await tester.pumpAndSettle();

    expect(find.byType(FirstPage), findsNothing);
    expect(find.byType(SecondPage), findsNothing);
    expect(find.byType(ThreePage), findsOneWidget);
  });

  testWidgets("Routes should work correctly with navigation with before screen",
      (tester) async {
    await tester.pumpWidget(makeTestableWidget());
    await tester.pumpAndSettle();

    await RouterMock.mockBeforeScreen(
      routerController: routerController,
      beforeNameRouter: RouterHandler.threeName,
      tester: tester,
    );

    expect(find.byType(FirstPage), findsOneWidget);
    expect(find.byType(SecondPage), findsNothing);

    routerController.popRouter();
    await tester.pumpAndSettle();

    expect(find.byType(ThreePage), findsOneWidget);
    expect(find.byType(FirstPage), findsNothing);
  });
}
