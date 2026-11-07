import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uxapp/widgets/chrome_collapse_controller.dart';

void main() {
  late ChromeCollapseController controller;

  Future<void> pump(WidgetTester tester) {
    controller = ChromeCollapseController();
    addTearDown(controller.dispose);
    return tester.pumpWidget(
      MaterialApp(
        home: NotificationListener<ScrollNotification>(
          onNotification: controller.onScroll,
          child: ListView.builder(
            itemCount: 300,
            itemBuilder: (_, i) => SizedBox(height: 60, child: Text('$i')),
          ),
        ),
      ),
    );
  }

  testWidgets('slow scrolling never collapses, however far', (tester) async {
    await pump(tester);
    await tester.timedDrag(
      find.byType(ListView),
      const Offset(0, -400),
      const Duration(seconds: 4),
    );
    await tester.pumpAndSettle();
    expect(controller.collapsed.value, isFalse);
  });

  testWidgets('a short fast drag does not collapse', (tester) async {
    await pump(tester);
    await tester.timedDrag(
      find.byType(ListView),
      const Offset(0, -40),
      const Duration(milliseconds: 40),
    );
    await tester.pumpAndSettle();
    expect(controller.collapsed.value, isFalse);
  });

  testWidgets('a fast sustained drag collapses, a fast drag back expands', (
    tester,
  ) async {
    await pump(tester);
    await tester.timedDrag(
      find.byType(ListView),
      const Offset(0, -300),
      const Duration(milliseconds: 150),
    );
    await tester.pumpAndSettle();
    expect(controller.collapsed.value, isTrue);
    await tester.timedDrag(
      find.byType(ListView),
      const Offset(0, 120),
      const Duration(milliseconds: 100),
    );
    await tester.pumpAndSettle();
    expect(controller.collapsed.value, isFalse);
  });

  testWidgets('a hard fling collapses and a hard fling back expands', (
    tester,
  ) async {
    await pump(tester);
    await tester.fling(find.byType(ListView), const Offset(0, -80), 2500);
    await tester.pumpAndSettle();
    expect(controller.collapsed.value, isTrue);
    await tester.fling(find.byType(ListView), const Offset(0, 80), 2500);
    await tester.pumpAndSettle();
    expect(controller.collapsed.value, isFalse);
  });

  testWidgets('returning to the top expands', (tester) async {
    await pump(tester);
    controller.collapse();
    await tester.drag(find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    controller.collapse();
    await tester.fling(find.byType(ListView), const Offset(0, 1200), 3000);
    await tester.pumpAndSettle();
    expect(controller.collapsed.value, isFalse);
  });
}
