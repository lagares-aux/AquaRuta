import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'user_provider.g.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });

  final String id;
  final String email;
  final String fullName;
  final String role; // 'passenger' o 'operator'

  factory UserProfile.fromMap(Map<String, dynamic> map, String email) {
    return UserProfile(
      id: map['id'] as String,
      email: email,
      fullName: (map['full_name'] ?? '') as String,
      role: (map['role'] ?? 'passenger') as String,
    );
  }
}

@riverpod
Future<UserProfile> userProfile(UserProfileRef ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) {
    throw Exception('No hay usuario autenticado');
  }

  final response = await supabase
      .from('profiles')
      .select('id, full_name, role')
      .eq('id', user.id)
      .maybeSingle();

  if (response == null) {
    throw Exception('Perfil no encontrado para el usuario actual');
  }

  return UserProfile.fromMap(response as Map<String, dynamic>, user.email ?? '');
}
