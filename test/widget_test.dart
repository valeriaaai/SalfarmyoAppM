import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salfarmyo_mobile/main.dart';

void main() {
  testWidgets('login screen renders branding and credentials fields', (
    tester,
  ) async {
    await tester.pumpWidget(const SalfarmyoApp());
    await tester.pump(const Duration(milliseconds: 1000));

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == 'assets/salfarmyoooo.png',
      ),
      findsOneWidget,
    );
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('LOG IN'), findsOneWidget);
  });
}
