import 'package:flutter_test/flutter_test.dart';
import 'package:sigej_flutter/data/local/local_database.dart';

void main() {
  test('carga datos iniciales', () async {
    final database = LocalDatabase();
    await database.init();

    expect(database.users, isNotEmpty);
    expect(database.records, isNotEmpty);
  });
}
