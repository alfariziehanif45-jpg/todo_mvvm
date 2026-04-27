import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:todo_mvvm/views/login_view.dart';

void main() {
  testWidgets('login screen renders core actions', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const MaterialApp(
        home: LoginView(),
      ),
    );

    expect(find.text('LOGIN'), findsOneWidget);
    expect(find.text('Belum punya akun? Register'), findsOneWidget);
  });
}
