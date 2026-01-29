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
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user != null) {
      // Crear el perfil asociado en public.profiles
      await _client.from('profiles').insert({
        'id': user.id,
        'full_name': fullName,
        'role': 'passenger',
      });
    }

    return user;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
