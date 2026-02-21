import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'auth_exceptions.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;
  final _storage = const FlutterSecureStorage();
  final GoogleSignIn googleSignIn = GoogleSignIn(
    clientId: '204192267818-6e4bhmfakicb44d5418vekvqo62kesvk.apps.googleusercontent.com',
    scopes: ['email', 'profile', 'openid'],
    forceCodeForRefreshToken: true,
  );

  Future<void> _saveSession(Session session) async {
    await _storage.write(key: 'session', value: jsonEncode(session.toJson()));
  }

  Future<void> _clearSession() async {
    await _storage.delete(key: 'session');
  }

  Future<Session?> recoverStoredSession() async {
    final sessionJson = await _storage.read(key: 'session');
    if (sessionJson == null) return null;

    try {
      final response = await supabase.auth.recoverSession(sessionJson);
      if (response.session != null) {
        await _saveSession(response.session!);
      }
      return response.session;
    } catch (e) {
      await _clearSession();
      return null;
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        await _saveSession(response.session!);
        await supabase
            .from('profiles')
            .update({'last_signup': DateTime.now().toIso8601String()})
            .eq('id', response.user!.id);
      }
    } on AuthException catch (e) {
      if (e.message == "Email not confirmed") {
        throw EmailNotConfirmedAuthException();
      }
      throw InvalidCredentialsAuthException();
    } catch (e) {
      throw GenericAuthException();
    }
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final emailAlreadyExists = await supabase.rpc(
        'email_exists',
        params: {'email_address': email},
      ) as bool;

      if (emailAlreadyExists) {
        throw EmailInUseAuthException();
      }

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );
      return response.session == null && response.user != null;
    } on AuthException catch (e) {
      if (e.message.contains("Password should be at least 6 characters")) {
        throw WeakPasswordAuthException();
      }
      throw GenericAuthException();
    } catch (e) {
      if (e is EmailInUseAuthException) rethrow;
      if (e.toString().contains('profiles_username_key')) {
        throw UsernameInUseAuthException();
      }
      throw GenericAuthException();
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );
      if (response.session != null) {
        await _saveSession(response.session!);
        await supabase
            .from('profiles')
            .update({'last_signup': DateTime.now().toIso8601String()})
            .eq('id', response.user!.id);
      } else {
        throw GenericAuthException();
      }
    } catch (e) {
      throw GenericAuthException();
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: kIsWeb ? null : 'fb1711951832780581://authorize',
      );
    } catch (e) {
      debugPrint('Facebook login error: $e');
      throw GenericAuthException();
    }
  }

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
      return data;
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  Future<void> sendPasswordResetOtp({required String email}) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      if (e.message.contains('User not found')) {
        throw UserNotFoundAuthException();
      }
      throw GenericAuthException();
    } catch (_) {
      throw GenericAuthException();
    }
  }

  Future<void> verifyPasswordResetOtp({
    required String email,
    required String token,
  }) async {
    try {
      final response = await supabase.auth.verifyOTP(
        type: OtpType.recovery,
        email: email,
        token: token,
      );
      if (response.session != null) {
        await _saveSession(response.session!);
      }
    } on AuthException catch (e) {
      if (e.message.contains('Token has expired or is invalid')) {
        throw InvalidOtpAuthException();
      }
      throw GenericAuthException();
    } catch (_) {
      throw GenericAuthException();
    }
  }

  Future<void> updateUserPassword(String newPassword) async {
    if (newPassword.length < 6) throw WeakPasswordAuthException();
    try {
      await supabase.auth.updateUser(UserAttributes(password: newPassword));
    } catch (_) {
      throw GenericAuthException();
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    await _clearSession();
    await googleSignIn.signOut();
    try {
      await FacebookAuth.instance.logOut();
    } catch (_) {}
  }

  bool isSignedIn() => supabase.auth.currentSession != null;

  Future<bool> isCurrentUserOnboardingComplete() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return true;

    try {
      final data = await supabase
          .from('profiles')
          .select('onboarding_complete')
          .eq('id', userId)
          .single();
      return data['onboarding_complete'] as bool? ?? false;
    } catch (e) {
      debugPrint('Profile not found on first attempt, retrying... Error: $e');
      await Future.delayed(const Duration(seconds: 2));

      try {
        final data = await supabase
            .from('profiles')
            .select('onboarding_complete')
            .eq('id', userId)
            .single();
        return data['onboarding_complete'] as bool? ?? false;
      } catch (finalError) {
        debugPrint('Error on second onboarding check attempt: $finalError');
        return false;
      }
    }
  }

  Future<void> completeOnboarding(Map<String, dynamic> profileData) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not logged in — cannot complete onboarding.');
    }

    final dataToUpdate = {
      ...profileData,
      'onboarding_complete': true,
      'updated_at': DateTime.now().toIso8601String(),
    };
    dataToUpdate.removeWhere(
      (key, value) => value == null || (value is String && value.isEmpty),
    );

    try {
      await supabase.from('profiles').update(dataToUpdate).eq('id', userId);
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
      throw GenericAuthException();
    }
  }

  Future<String?> uploadProfileAvatar(XFile imageFile) async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final file = File(imageFile.path);
      final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await supabase.storage.from('avatars').upload(
            fileName,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      return supabase.storage.from('avatars').getPublicUrl(fileName);
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      return null;
    }
  }

  Future<void> updateProfileData(Map<String, dynamic> data) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw GenericAuthException();

    try {
      final updates = {
        ...data,
        'updated_at': DateTime.now().toIso8601String(),
      };
      await supabase.from('profiles').update(updates).eq('id', user.id);
    } catch (e) {
      debugPrint('Error updating profile: $e');
      throw GenericAuthException();
    }
  }

  Future<void> deleteAccount(String password, String reason) async {
    final user = supabase.auth.currentUser;
    if (user == null || user.email == null) throw GenericAuthException();

    try {
      await supabase.auth.signInWithPassword(
        email: user.email!,
        password: password,
      );
      await supabase.rpc('delete_user_account', params: {'feedback_reason': reason});
      await signOut();
    } on AuthException {
      throw InvalidCredentialsAuthException();
    } catch (e) {
      debugPrint('Error deleting account: $e');
      throw GenericAuthException();
    }
  }
}
