import 'package:example/main.dart';
import 'package:example/pages/first_page.dart';
import 'package:example/pages/second_page.dart';
import 'package:example/pages/three_page.dart';
import 'package:example/router/navigation_controller.dart';
import 'package:example/router/router_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:router_controller/router_controller.dart';
import 'mock/router_mock.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late Finder firstPageFinder;
  late Finder secondPageFinder;
  late Finder threePageFinder;

  late NavigationController routerController;

  Widget makeTestableWidget() => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: routerController),
        ],
        child: MaterialApp(
          navigatorKey: navigationApp,
          onGenerateRoute: routerController.router.generator,
        ),
      );

  setUpAll(() {
    firstPageFinder = find.byType(FirstPage);
    secondPageFinder = find.byType(SecondPage);
    threePageFinder = find.byType(ThreePage);
  });

  setUp(() {
    routerController = NavigationController();

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

    expect(firstPageFinder, findsOneWidget);
    expect(secondPageFinder, findsNothing);
    expect(threePageFinder, findsNothing);

    routerController.navigateWithName(nameRouter: RouterHandler.secondName);
    await tester.pumpAndSettle();

    expect(firstPageFinder, findsNothing);
    expect(secondPageFinder, findsOneWidget);
    expect(threePageFinder, findsNothing);

    routerController.navigateWithName(nameRouter: RouterHandler.threeName);
    await tester.pumpAndSettle();

    expect(firstPageFinder, findsNothing);
    expect(secondPageFinder, findsNothing);
    expect(threePageFinder, findsOneWidget);
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

    expect(firstPageFinder, findsOneWidget);
    expect(secondPageFinder, findsNothing);

    routerController.popRouter();
    await tester.pumpAndSettle();

    expect(threePageFinder, findsOneWidget);
    expect(firstPageFinder, findsNothing);
  });

  testWidgets(
      "Routes should work correctly with navigation with replace the current widget with the three screen ",
      (WidgetTester tester) async {
    await tester.pumpWidget(makeTestableWidget());
    await tester.pumpAndSettle();

    expect(firstPageFinder, findsOneWidget);
    expect(secondPageFinder, findsNothing);
    expect(threePageFinder, findsNothing);

    routerController.navigateWithName(nameRouter: RouterHandler.secondName);
    await tester.pumpAndSettle();

    expect(firstPageFinder, findsNothing);
    expect(secondPageFinder, findsOneWidget);
    expect(threePageFinder, findsNothing);

    routerController.navigateReplacementWithWidget(
      widget: const ThreePage(),
    );
    await tester.pumpAndSettle();

    expect(firstPageFinder, findsNothing);
    expect(secondPageFinder, findsNothing);
    expect(threePageFinder, findsOneWidget);

    routerController.popRouter();
    await tester.pumpAndSettle();

    expect(firstPageFinder, findsOneWidget);
    expect(secondPageFinder, findsNothing);
    expect(threePageFinder, findsNothing);
  });

  testWidgets(
      "Routes should work correctly with navigation with replace named the second screen with the three screen",
      (WidgetTester tester) async {
    await tester.pumpWidget(makeTestableWidget());
    await tester.pumpAndSettle();

    expect(firstPageFinder, findsOneWidget);
    expect(secondPageFinder, findsNothing);
    expect(threePageFinder, findsNothing);

    routerController.navigateWithName(nameRouter: RouterHandler.secondName);
    await tester.pumpAndSettle();

    expect(firstPageFinder, findsNothing);
    expect(secondPageFinder, findsOneWidget);
    expect(threePageFinder, findsNothing);

    routerController.navigateReplacementNamed(
        nameRouter: RouterHandler.threeName);
    await tester.pumpAndSettle();

    expect(firstPageFinder, findsNothing);
    expect(secondPageFinder, findsNothing);
    expect(threePageFinder, findsOneWidget);

    routerController.popRouter();
    await tester.pumpAndSettle();

    expect(firstPageFinder, findsOneWidget);
    expect(secondPageFinder, findsNothing);
    expect(threePageFinder, findsNothing);
  });
}
