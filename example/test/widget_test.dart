import 'package:adrop_ads_flutter_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App should build', (WidgetTester tester) async {
    await tester.pumpWidget(const AdropExampleApp());
    expect(find.text('Adrop'), findsWidgets);
  });
}
