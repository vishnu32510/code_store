import 'package:code_store_auth/code_store_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LoginBottomSheet renders title and form elements', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoginBottomSheet(
            title: 'Welcome Back',
            subtitle: 'Please log in to continue',
          ),
        ),
      ),
    );

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Please log in to continue'), findsOneWidget);
    expect(find.text('Continue with Email'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
