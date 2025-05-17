import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Auth', () {
    final provider = MockAuthProvider();
    test('should not be initialized', () {
      expect(provider.isInitialized, false);
    });
    test('cannot logout if not initialized', () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });
    test('should be able to be initialized', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });
    test('user should be null after initialization', () {
      expect(provider.currentUser, null);
    });
    test(
      'should be able to initialize in less than 2 secs',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );
    test('create user should delegate to login func', () async {
      final badEmailUser = provider.createUser(
        email: 'meeka@gmail.com',
        password: "123",
      );
      expect(
        badEmailUser,
        throwsA(const TypeMatcher<UserNotFoundAuthException>()),
      );
      final badPasswordUser = provider.createUser(
        email: 'rhea@gmail.com',
        password: 'qwerty',
      );
      expect(
        badPasswordUser,
        throwsA(const TypeMatcher<WrongPaswordAuthException>()),
      );
      final user = await provider.createUser(
        email: 'rhea@gmail.com',
        password: '123456',
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });
    test('check email verification', () async {
      await provider.sendEmailVerification();
      expect(provider.currentUser?.isEmailVerified, true);
    });
    test('should be able to logout and login', () async {
      await provider.logOut();
      await provider.logIn(email: 'mhysa', password: '123');
      expect(provider.currentUser, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) {
      throw NotInitializedException();
    }
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if (!isInitialized) {
      throw NotInitializedException();
    }
    if (email == "meeka@gmail.com") throw UserNotFoundAuthException();
    if (password == 'qwerty') throw WrongPaswordAuthException();
    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) {
      throw NotInitializedException();
    }
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) {
      throw NotInitializedException();
    }
    if (_user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
  }
}
