import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_mobile_app/features/catalog/domain/product.dart';
import 'package:pos_mobile_app/features/catalog/data/catalog_repository.dart';
import 'package:pos_mobile_app/features/pos/presentation/cart_notifier.dart';
import 'package:pos_mobile_app/features/pos/presentation/widgets/variant_selector_dialog.dart';

void main() {
  group('Product Variants & Authentic Bakery Catalog Tests', () {
    test('Catalog contains authentic Mexican & artisan bakery categories and Concha variants', () {
      final concha = CatalogRepositoryImpl.defaultProducts.firstWhere(
        (p) => p.sku == 'PAST-CONC',
      );

      expect(concha.name, 'Concha Tradicional');
      expect(concha.category, 'Panes de Dulce');
      expect(concha.hasVariants, isTrue);
      expect(concha.variants.length, 4);

      final vanilla = concha.variants.firstWhere((v) => v.name == 'Vainilla Tradicional');
      final chocolate = concha.variants.firstWhere((v) => v.name == 'Chocolate Belga');
      final nuez = concha.variants.firstWhere((v) => v.name == 'Nuez y Canela');

      expect(vanilla.priceDeltaCents, 0);
      expect(chocolate.priceDeltaCents, 0);
      expect(nuez.priceDeltaCents, 25); // +$0.25 extra
    });

    test('CartNotifier adds products with specific flavor variants and computes correct totals', () {
      final container = ProviderContainer();
      final notifier = container.read(cartNotifierProvider.notifier);

      final concha = CatalogRepositoryImpl.defaultProducts.firstWhere(
        (p) => p.sku == 'PAST-CONC',
      );
      final chocolateVariant = concha.variants.firstWhere((v) => v.name == 'Chocolate Belga');
      final nuezVariant = concha.variants.firstWhere((v) => v.name == 'Nuez y Canela');

      // Add 2 chocolate conchas ($2.50 ea)
      notifier.addProduct(concha, variant: chocolateVariant);
      notifier.addProduct(concha, variant: chocolateVariant);

      // Add 1 nuez concha ($2.75 ea)
      notifier.addProduct(concha, variant: nuezVariant);

      final cartState = container.read(cartNotifierProvider);
      expect(cartState.itemCount, 3);
      expect(cartState.items.length, 2); // 2 distinct cart keys

      final chocItem = cartState.items['${concha.id}_${chocolateVariant.id}'];
      expect(chocItem, isNotNull);
      expect(chocItem!.quantity, 2);
      expect(chocItem.unitPriceCents, 250);
      expect(chocItem.itemTotalCents, 500);
      expect(chocItem.displayName, 'Concha Tradicional (Chocolate Belga)');

      final nuezItem = cartState.items['${concha.id}_${nuezVariant.id}'];
      expect(nuezItem, isNotNull);
      expect(nuezItem!.quantity, 1);
      expect(nuezItem.unitPriceCents, 275);
      expect(nuezItem.itemTotalCents, 275);
      expect(nuezItem.displayName, 'Concha Tradicional (Nuez y Canela)');

      // Subtotal = 500 + 275 = 775 cents ($7.75)
      expect(cartState.subtotalCents, 775);
    });

    testWidgets('VariantSelectorDialog renders flavors and fires callback on selection', (tester) async {
      final concha = CatalogRepositoryImpl.defaultProducts.firstWhere(
        (p) => p.sku == 'PAST-CONC',
      );

      ProductVariant? chosenVariant;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => VariantSelectorDialog(
                      product: concha,
                      onSelectVariant: (v) => chosenVariant = v,
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Concha Tradicional'), findsOneWidget);
      expect(find.text('Selecciona tu sabor o preparación'), findsOneWidget);
      expect(find.text('Vainilla Tradicional'), findsOneWidget);
      expect(find.text('Chocolate Belga'), findsOneWidget);
      expect(find.text('Fresa Silvestre'), findsOneWidget);
      expect(find.text('Nuez y Canela'), findsOneWidget);
      expect(find.text('+ \$0.25 adicional'), findsOneWidget);

      // Tap on Chocolate Belga
      await tester.tap(find.text('Chocolate Belga'));
      await tester.pumpAndSettle();

      expect(chosenVariant, isNotNull);
      expect(chosenVariant!.name, 'Chocolate Belga');
    });
  });
}
