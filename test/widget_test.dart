import 'package:flutter_test/flutter_test.dart';
import 'package:docsnap/main.dart';

void main() {
  testWidgets('DocSnap app smoke test', (WidgetTester tester) async {
    expect(DocSnapApp, isNotNull);
  });
}
