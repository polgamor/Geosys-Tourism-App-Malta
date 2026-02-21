import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/auth_exceptions.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? get profileData => _profileData;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  final List<String> availableGenders = const ['Male', 'Female', 'Other'];
  final List<String> availableTravelStyles = const ['Solo', 'Couple', 'Family', 'Friends'];
  final List<String> availableBudgetTiers = const ['Budget', 'Mid-range', 'Luxury'];
  final List<String> availablePreferences = const [
    'Beaches', 'Parties', 'Restaurants', 'Culture', 'History',
    'Adventure', 'Relax', 'Shopping', 'Nature', 'Sports',
  ];

  ProfileViewModel() {
    loadProfile();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> loadProfile() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _profileData = await _authService.getCurrentUserProfile();
    } catch (e) {
      _errorMessage = 'Failed to load profile data.';
    } finally {
      _setLoading(false);
    }
  }

  Future<XFile?> pickImageFromGallery() async {
    return _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
  }

  Future<bool> saveProfileChanges({
    required Map<String, dynamic> updatedData,
    XFile? newAvatarFile,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      if (newAvatarFile != null) {
        final avatarUrl = await _authService.uploadProfileAvatar(newAvatarFile);
        if (avatarUrl != null) updatedData['avatar_url'] = avatarUrl;
      }
      await _authService.updateProfileData(updatedData);
      await loadProfile();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> deleteCurrentUserAccount(String password, String reason) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await _authService.deleteAccount(password, reason);
      return null;
    } on AuthServiceException catch (e) {
      _errorMessage = e.message;
      _setLoading(false);
      return e.message;
    }
  }

  Future<void> signOut() async => _authService.signOut();
}
