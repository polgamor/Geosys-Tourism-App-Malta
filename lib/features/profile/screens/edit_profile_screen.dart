import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../viewmodel/profile_viewmodel.dart';
import '../../login/screens/login_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _surnameController;
  late final TextEditingController _countryController;
  late final TextEditingController _ageController;

  late List<String> _selectedPreferences;
  String? _selectedGender;
  String? _selectedTravelStyle;
  String? _selectedBudgetTier;
  DateTime? _tripStartDate;
  DateTime? _tripEndDate;
  XFile? _newAvatarFile;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
      if (viewModel.profileData != null) {
        _initializeFields(viewModel.profileData!);
      }
    });
  }

  void _initializeFields(Map<String, dynamic> profile) {
    _nameController = TextEditingController(text: profile['name']);
    _surnameController = TextEditingController(text: profile['surname']);
    _countryController = TextEditingController(text: profile['country']);
    _ageController = TextEditingController(text: profile['age']?.toString());
    
    _selectedGender = profile['gender'];
    _selectedTravelStyle = profile['travel_style'];
    _selectedBudgetTier = profile['budget_tier'];

    try {
      _tripStartDate = profile['trip_start_date'] != null ? DateTime.parse(profile['trip_start_date']) : null;
      _tripEndDate = profile['trip_end_date'] != null ? DateTime.parse(profile['trip_end_date']) : null;
    } catch (_) {
      _tripStartDate = null;
      _tripEndDate = null;
    }

    final preferencesRaw = profile['preferences'] as List<dynamic>? ?? [];
    _selectedPreferences = preferencesRaw.map((item) => item.toString()).toList();
    
    setState(() {});
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _countryController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();

    if (viewModel.profileData == null || !mounted) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent, 
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: viewModel.isLoading ? null : () => _saveChanges(context, viewModel),
            child: viewModel.isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: Container(
         decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/login_background.jpg'),
              fit: BoxFit.cover,
              opacity: 0.2
            ),
          ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: _buildAvatarPicker(viewModel)),
                const SizedBox(height: 32),
                _buildSectionTitle('Personal Info'),
                _buildStyledTextField(controller: _nameController, hintText: 'Name'),
                const SizedBox(height: 16),
                _buildStyledTextField(controller: _surnameController, hintText: 'Surname'),
                const SizedBox(height: 16),
                _buildStyledTextField(controller: _ageController, hintText: 'Age', keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildDropdownField('Gender', _selectedGender, viewModel.availableGenders, (val) => setState(() => _selectedGender = val)),
                const SizedBox(height: 16),
                _buildStyledTextField(controller: _countryController, hintText: 'Country'),
                const SizedBox(height: 32),
                _buildSectionTitle('Trip Details'),
                _buildDropdownField('Travel Style', _selectedTravelStyle, viewModel.availableTravelStyles, (val) => setState(() => _selectedTravelStyle = val)),
                const SizedBox(height: 16),
                _buildDropdownField('Budget', _selectedBudgetTier, viewModel.availableBudgetTiers, (val) => setState(() => _selectedBudgetTier = val)),
                const SizedBox(height: 16),
                _buildDateRangePicker(context),
                const SizedBox(height: 32),
                _buildSectionTitle('Interests'),
                _buildPreferencesChips(viewModel),
                const SizedBox(height: 40),
                const Divider(color: Colors.white24),
                const SizedBox(height: 20),
                Center(
                  child: TextButton.icon(
                    icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                    label: const Text('Delete Account', style: TextStyle(color: Colors.redAccent)),
                    onPressed: () => _showDeleteAccountDialog(context, viewModel),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveChanges(BuildContext context, ProfileViewModel viewModel) async {
    final updatedData = {
      'name': _nameController.text.trim(),
      'surname': _surnameController.text.trim(),
      'country': _countryController.text.trim(),
      'age': int.tryParse(_ageController.text.trim()),
      'gender': _selectedGender,
      'travel_style': _selectedTravelStyle,
      'budget_tier': _selectedBudgetTier,
      'trip_start_date': _tripStartDate?.toIso8601String(),
      'trip_end_date': _tripEndDate?.toIso8601String(),
      'preferences': _selectedPreferences,
    };
    final success = await viewModel.saveProfileChanges(updatedData: updatedData, newAvatarFile: _newAvatarFile);
    if (success && mounted) {
      setState(() => _newAvatarFile = null);
      Navigator.of(context).pop();
    }
  }

  Widget _buildAvatarPicker(ProfileViewModel viewModel) {
     return Stack(
      alignment: Alignment.bottomRight,
      children: [
        _buildAvatarDisplay(viewModel),
        InkWell(
          onTap: () async {
            final file = await viewModel.pickImageFromGallery();
            if (file != null) setState(() => _newAvatarFile = file);
          },
          child: CircleAvatar(
            radius: 22,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            child: const CircleAvatar(
              radius: 20,
              backgroundColor: Color.fromARGB(255, 29, 168, 64),
              child: Icon(Icons.camera_alt, size: 20, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildAvatarDisplay(ProfileViewModel viewModel) {
    if (_newAvatarFile != null) {
      return CircleAvatar(
        radius: 60,
        backgroundImage: FileImage(File(_newAvatarFile!.path)),
      );
    }
    final avatarUrl = viewModel.profileData?['avatar_url'];
    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.black.withOpacity(0.5),
      backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? CachedNetworkImageProvider(avatarUrl) : null,
      child: (avatarUrl == null || avatarUrl.isEmpty) ? const Icon(Icons.person, size: 60, color: Colors.white70) : null,
    );
  }

  Widget _buildDropdownField(String hint, String? value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      hint: Text(hint, style: TextStyle(color: Colors.grey.shade400)),
      dropdownColor: const Color(0xFF2E2E2E),
      style: const TextStyle(color: Colors.white),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      decoration: _getStyledInputDecoration(),
    );
  }

  Widget _buildDateRangePicker(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final String buttonText = _tripStartDate != null && _tripEndDate != null
      ? "${dateFormat.format(_tripStartDate!)} - ${dateFormat.format(_tripEndDate!)}"
      : "Select your trip dates";
      
    return GestureDetector(
      onTap: () async {
        final dateRange = await showDateRangePicker(
          context: context,
          initialDateRange: _tripStartDate != null ? DateTimeRange(start: _tripStartDate!, end: _tripEndDate!) : null,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
           builder: (context, child) => Theme(data: ThemeData.dark(), child: child!),
        );
        if (dateRange != null) {
          setState(() {
            _tripStartDate = dateRange.start;
            _tripEndDate = dateRange.end;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(buttonText, style: TextStyle(color: _tripStartDate != null ? Colors.white : Colors.grey.shade400, fontSize: 16)),
            const Icon(Icons.calendar_today, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesChips(ProfileViewModel viewModel) {
    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children: viewModel.availablePreferences.map((preference) {
        final isSelected = _selectedPreferences.contains(preference);
        return FilterChip(
          label: Text(preference),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedPreferences.add(preference);
              } else {
                _selectedPreferences.remove(preference);
              }
            });
          },
          backgroundColor: Colors.black.withOpacity(0.3),
          labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
          selectedColor: Colors.white,
          checkmarkColor: Colors.black,
          shape: StadiumBorder(side: BorderSide(color: isSelected ? Colors.white : Colors.white54)),
        );
      }).toList(),
    );
  }

  Widget _buildStyledTextField({required TextEditingController controller, required String hintText, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      inputFormatters: keyboardType == TextInputType.number ? [FilteringTextInputFormatter.digitsOnly] : [],
      decoration: _getStyledInputDecoration(hintText: hintText),
    );
  }
  
  InputDecoration _getStyledInputDecoration({String? hintText}) {
    return InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color.fromARGB(255, 29, 168, 64))),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20));
  }
  
  Widget _buildSectionTitle(String title) => Padding(padding: const EdgeInsets.only(bottom: 12.0), child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)));
  
  void _showDeleteAccountDialog(BuildContext context, ProfileViewModel viewModel) {
     final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? reason;
    final reasons = ['No longer need it', 'Privacy concerns', 'Found a better app', 'Other'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF212121),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              title: const Text('Delete Account', style: TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('This action is permanent. Please provide a reason and confirm with your password.', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<String>(
                        initialValue: reason,
                        hint: const Text('Reason for leaving*', style: TextStyle(color: Colors.white70)),
                        dropdownColor: const Color(0xFF212121),
                        style: const TextStyle(color: Colors.white),
                        items: reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                        onChanged: (value) => setDialogState(() => reason = value),
                        validator: (value) => value == null ? 'Please select a reason' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Confirm Password*', labelStyle: TextStyle(color: Colors.white70)),
                        validator: (value) => value == null || value.isEmpty ? 'Password is required' : null,
                      ),
                      Consumer<ProfileViewModel>(
                        builder: (context, vm, _) {
                           if (vm.errorMessage != null) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(vm.errorMessage!, style: const TextStyle(color: Colors.redAccent)),
                            );
                           }
                           return const SizedBox.shrink();
                        }
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: viewModel.isLoading ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          if (formKey.currentState?.validate() != true) return;
                          
                          final error = await viewModel.deleteCurrentUserAccount(
                            passwordController.text,
                            reason!
                          );

                          if (error == null && mounted) {
                            Navigator.of(dialogContext).pop(); 
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Account deleted successfully.'), backgroundColor: Colors.green),
                            );
                          } 
                          else if (mounted) {
                            showDialog(
                              context: dialogContext, 
                              builder: (errorDialogContext) => AlertDialog(
                                backgroundColor: const Color(0xFF212121),
                                title: const Text('Deletion Failed', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                content: Text(
                                  error!, 
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(errorDialogContext).pop(); 
                                    },
                                    child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                  child: viewModel.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}