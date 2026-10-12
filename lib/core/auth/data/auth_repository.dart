import 'dart:async';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/user_role.dart';

class AuthRepository {
  const AuthRepository();

  Future<AuthUser?> getCurrentUser() async {
    try {
      if (!Amplify.isConfigured) return null;
      return await Amplify.Auth.getCurrentUser();
    } catch (_) {
      return null;
    }
  }

  Future<UserRole> getCurrentUserRole() async {
    try {
      if (!Amplify.isConfigured) return UserRole.guest;
      final session = await Amplify.Auth.fetchAuthSession();
      if (!session.isSignedIn) {
        return UserRole.guest;
      }

      if (session is CognitoAuthSession) {
        final tokens = session.userPoolTokensResult.value;
        final claims = tokens.idToken.claims;
        final rawGroups = claims.toJson()['cognito:groups'];

        List<String> groups = [];
        if (rawGroups is List) {
          groups = rawGroups.map((e) => e.toString()).toList();
        } else if (rawGroups is String) {
          groups = [rawGroups];
        }

        for (final group in groups) {
          final normalized = group.trim().toLowerCase();
          if (normalized == 'admins' || normalized == 'admin') {
            return UserRole.admin;
          }
          if (normalized == 'managers' || normalized == 'manager') {
            return UserRole.manager;
          }
          if (normalized == 'workers' || normalized == 'worker') {
            return UserRole.worker;
          }
          if (normalized == 'drivers' || normalized == 'driver') {
            return UserRole.driver;
          }
          if (normalized == 'customers' || normalized == 'customer') {
            return UserRole.customer;
          }
        }
      }

      return UserRole.customer;
    } catch (_) {
      return UserRole.guest;
    }
  }

  Future<SignInResult> signIn(String email, String password) async {
    return await Amplify.Auth.signIn(
      username: email,
      password: password,
    );
  }

  Future<void> confirmSignInWithNewPassword(String newPassword) async {
    await Amplify.Auth.confirmSignIn(
      confirmationValue: newPassword,
    );
  }

  Future<void> signOut() async {
    await Amplify.Auth.signOut();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return const AuthRepository();
});

class AuthStateNotifier extends AsyncNotifier<UserRole> {
  StreamSubscription<AuthHubEvent>? _hubSubscription;

  @override
  Future<UserRole> build() async {
    final repo = ref.watch(authRepositoryProvider);

    if (Amplify.isConfigured) {
      _hubSubscription?.cancel();
      _hubSubscription = Amplify.Hub.listen(HubChannel.Auth, (event) {
        refresh();
      });
      ref.onDispose(() {
        _hubSubscription?.cancel();
      });
    }

    return repo.getCurrentUserRole();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      return repo.getCurrentUserRole();
    });
  }

  Future<SignInResult> signIn(String email, String password) async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.signIn(email, password);
    if (result.isSignedIn) {
      await refresh();
    }
    return result;
  }

  Future<void> confirmSignInWithNewPassword(String newPassword) async {
    final repo = ref.read(authRepositoryProvider);
    await repo.confirmSignInWithNewPassword(newPassword);
    await refresh();
  }

  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
    await refresh();
  }
}

final authStateProvider =
    AsyncNotifierProvider<AuthStateNotifier, UserRole>(() {
  return AuthStateNotifier();
});

final currentUserProvider = FutureProvider<AuthUser?>((ref) async {
  ref.watch(authStateProvider);
  final repo = ref.watch(authRepositoryProvider);
  return repo.getCurrentUser();
});
