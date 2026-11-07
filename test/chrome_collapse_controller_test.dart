import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uxapp/widgets/chrome_collapse_controller.dart';

void main() {
  late ChromeCollapseController controller;

  Future<void> pump(WidgetTester tester) {
    controller = ChromeCollapseController();
    return tester.pumpWidget(
      MaterialApp(
        home: NotificationListener<ScrollNotification>(
          onNotification: controller.onScroll,
          child: ListView.builder(
            itemCount: 200,
            itemBuilder: (_, i) => SizedBox(height: 60, child: Text('$i')),
          ),
        ),
      ),
    );
  }

  testWidgets('small drag does not collapse', (tester) async {
    await pump(tester);
    await tester.drag(find.byType(ListView), const Offset(0, -30));
    await tester.pumpAndSettle();
    expect(controller.collapsed, isFalse);
  });

  testWidgets('sustained drag down collapses, drag up expands', (tester) async {
    await pump(tester);
    await tester.drag(find.byType(ListView), const Offset(0, -120));
    await tester.pumpAndSettle();
    expect(controller.collapsed, isTrue);
    await tester.drag(find.byType(ListView), const Offset(0, 50));
    await tester.pumpAndSettle();
    expect(controller.collapsed, isFalse);
  });

  testWidgets('fling collapses and fling back expands', (tester) async {
    await pump(tester);
    await tester.fling(find.byType(ListView), const Offset(0, -80), 1500);
    await tester.pumpAndSettle();
    expect(controller.collapsed, isTrue);
    await tester.fling(find.byType(ListView), const Offset(0, 80), 1500);
    await tester.pumpAndSettle();
    expect(controller.collapsed, isFalse);
  });

  testWidgets('returning to the top expands', (tester) async {
    await pump(tester);
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(controller.collapsed, isTrue);
    await tester.fling(find.byType(ListView), const Offset(0, 600), 200);
    await tester.pumpAndSettle();
    expect(controller.collapsed, isFalse);
  });
}
