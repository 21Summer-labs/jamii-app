import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:your_app_name/middleware/state_management.dart';

void main() {
  group('StateManagementMiddleware Tests', () {
    testWidgets('StateManagementMiddleware should provide AppState', (WidgetTester tester) async {
      await tester.pumpWidget(
        StateManagementMiddleware(
          child: Builder(
            builder: (BuildContext context) {
              final appState = Provider.of<AppState>(context, listen: false);
              expect(appState, isNotNull);
              expect(appState, isA<AppState>());
              return Container();
            },
          ),
        ),
      );
    });
  });

  // Add tests for other middlewares
}