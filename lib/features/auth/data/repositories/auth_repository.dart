import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  Stream<User?> get authStateChanges => _client.auth.onAuthStateChange
      .map((event) => event.session?.user);

  Future<User?> signIn({required String email, required String password}) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.user;
  }

  Future<User?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String role,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: <String, dynamic>{
        'full_name': fullName,
        'role': role,
      },
    );

    return response.user;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
