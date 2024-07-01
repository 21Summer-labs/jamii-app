import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:your_app_name/controllers/user_controller.dart';
import 'package:your_app_name/services/auth_service.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  group('UserController Tests', () {
    late UserController userController;
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
      userController = UserController();
      // Inject the mock service
      // Note: This assumes you've made _authService public or added a setter
      userController.authService = mockAuthService;
    });

    test('signIn should call authService.signInWithEmailAndPassword', () async {
      when(mockAuthService.signInWithEmailAndPassword(any, any))
          .thenAnswer((_) async => null);

      await userController.signIn('test@example.com', 'password');

      verify(mockAuthService.signInWithEmailAndPassword('test@example.com', 'password')).called(1);
    });

    // Add more tests for other UserController methods
  });

  // Add tests for other controllers
}