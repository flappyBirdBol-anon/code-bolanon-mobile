import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  final _supabase = Supabase.instance.client;
  final _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    clientId: 'YOUR_CLIENT_ID',
    serverClientId: 'YOUR_SERVER_CLIENT_ID',
  );

  Future<UserModel> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required String role,
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'role': role,
        'trainer_info': role == 'trainer' ? metadata : null,
      },
    );

    if (response.user == null) {
      throw Exception('Signup failed');
    }

    return UserModel(
      id: response.user!.id,
      name: name,
      email: email,
      role: role,
      trainerInfo: metadata,
    );
  }

  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Login failed');
    }

    // Fetch user data from your database
    final userData = await _supabase
        .from('users')
        .select()
        .eq('id', response.user!.id)
        .single();

    return UserModel.fromJson(userData);
  }

  Future<UserModel> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google sign in cancelled');
    }

    final googleAuth = await googleUser.authentication;
    final response = await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: googleAuth.idToken!,
      accessToken: googleAuth.accessToken,
    );

    if (response.user == null) {
      throw Exception('Google sign in failed');
    }

    return UserModel(
      id: response.user!.id,
      name: googleUser.displayName ?? '',
      email: googleUser.email,
      role: 'trainee', // Default role for Google sign in
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    await _googleSignIn.signOut();
  }
}
