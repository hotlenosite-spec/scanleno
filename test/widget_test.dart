import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:scanleno/app/scanleno_app.dart';

void main() {
  testWidgets('ScanLeno renders its localized application shell', (
    tester,
  ) async {
    await tester.pumpWidget(const ScanLenoApp());
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Files'), findsOneWidget);
  });

  testWidgets('Arabic locale uses RTL directionality', (tester) async {
    await tester.pumpWidget(const ScanLenoApp(locale: Locale('ar')));
    await tester.pumpAndSettle();

    expect(
      Directionality.of(tester.element(find.text('الرئيسية').first)),
      TextDirection.rtl,
    );
  });
}
