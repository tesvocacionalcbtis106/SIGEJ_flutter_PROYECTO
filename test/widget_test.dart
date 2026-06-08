// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:sigej_flutter/data/local/local_database.dart';

void main() {
  test('estructura base SIGEJ disponible', () async {
    final database = LocalDatabase();
    await database.init();

    expect(database.users.length, greaterThanOrEqualTo(2));
  });
}
