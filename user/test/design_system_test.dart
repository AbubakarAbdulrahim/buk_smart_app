import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartbuk/core/theme/phosphor_compat.dart';
import 'package:smartbuk/core/theme/app_colors.dart';
import 'package:smartbuk/widgets/app_widgets.dart';

void main() {
  test('accessible action blue remains based on the BUK blue palette', () {
    expect(AppColors.primary, 0xFF0085D0);
    expect(AppColors.primaryAction, 0xFF006EA8);
  });

  testWidgets('quick action card fits a compact tile and handles taps', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(AppColors.primary),
          ),
        ),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 136,
              height: 136,
              child: QuickActionCard(
                title: 'Emergency Contacts',
                description: 'Quick access to campus emergency numbers',
                icon: PhosphorIconsRegular.phoneCall,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Emergency Contacts'), findsOneWidget);
    expect(
      tester
          .widgetList<Icon>(find.byIcon(PhosphorIconsRegular.phoneCall))
          .any((icon) => icon.size == 160),
      isTrue,
    );

    await tester.tap(find.byType(QuickActionCard));
    expect(tapped, isTrue);
  });
}
