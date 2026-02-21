import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import '../../../../../data/services/auth_service.dart';

enum OnboardingState { loading, ready }

class OnboardingViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  final PageController pageController = PageController();
  int _currentPage = 0;
  int get currentPage => _currentPage;
  // Aumentamos el número total de páginas
  final int totalPages = 6;

  OnboardingState _state = OnboardingState.loading;
  OnboardingState get state => _state;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Controladores existentes
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final ageController = TextEditingController();

  Country? _selectedCountry;
  Country? get selectedCountry => _selectedCountry;

  String? _selectedGender;
  String? get selectedGender => _selectedGender;
  final List<String> availableGenders = ['Male', 'Female', 'Other'];

  final Set<String> _selectedPreferences = {};
  Set<String> get selectedPreferences => Set.unmodifiable(_selectedPreferences);

  final List<String> availablePreferences = const [
    'Beaches', 'Parties', 'Restaurants', 'Culture', 'History',
    'Adventure', 'Relax', 'Shopping', 'Nature', 'Sports'
  ];
  
  // --- NUEVOS CAMPOS ---
  String? _selectedTravelStyle;
  String? get selectedTravelStyle => _selectedTravelStyle;
  final List<String> availableTravelStyles = ['Solo', 'Couple', 'Family', 'Friends'];

  String? _selectedBudgetTier;
  String? get selectedBudgetTier => _selectedBudgetTier;
  final List<String> availableBudgetTiers = ['Budget', 'Mid-range', 'Luxury'];

  DateTime? _tripStartDate;
  DateTime? get tripStartDate => _tripStartDate;
  DateTime? _tripEndDate;
  DateTime? get tripEndDate => _tripEndDate;
  // --- FIN DE NUEVOS CAMPOS ---


  OnboardingViewModel() {
    pageController.addListener(() {
      final newPage = pageController.page?.round();
      if (newPage != null && newPage != _currentPage) {
        _currentPage = newPage;
        notifyListeners();
      }
    });
    _initialize();
  }

  Future<void> _initialize() async {
    final profileData = await _authService.getCurrentUserProfile();
    if (profileData != null) {
      final name = profileData['name'] as String?;
      final surname = profileData['surname'] as String?;

      if (name != null && name.isNotEmpty) nameController.text = name;
      if (surname != null && surname.isNotEmpty) surnameController.text = surname;

      if (nameController.text.isNotEmpty && surnameController.text.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (pageController.hasClients) {
            pageController.jumpToPage(1);
          }
        });
      }
    }
    _state = OnboardingState.ready;
    notifyListeners();
  }

  // --- MÉTODOS PARA LOS NUEVOS DATOS ---
  void selectTravelStyle(String style) {
    _selectedTravelStyle = style;
    notifyListeners();
  }

  void selectBudgetTier(String tier) {
    _selectedBudgetTier = tier;
    notifyListeners();
  }

  void setTripDates(DateTime start, DateTime end) {
    _tripStartDate = start;
    _tripEndDate = end;
    notifyListeners();
  }
  // --- FIN DE MÉTODOS PARA NUEVOS DATOS ---

  void selectCountry(Country country) {
    _selectedCountry = country;
    notifyListeners();
  }

  void selectGender(String gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  void togglePreference(String preference) {
    _selectedPreferences.contains(preference)
        ? _selectedPreferences.remove(preference)
        : _selectedPreferences.add(preference);
    notifyListeners();
  }

  void nextPage() {
    _errorMessage = null;
    // Validaciones para cada página
    switch (_currentPage) {
      case 0:
        if (nameController.text.trim().isEmpty || surnameController.text.trim().isEmpty) {
          _errorMessage = "Name and surname cannot be empty.";
        }
        break;
      case 1:
        if (_selectedCountry == null) {
          _errorMessage = "Please select your country.";
        }
        break;
      case 2:
        if (_selectedGender == null || ageController.text.trim().isEmpty) {
          _errorMessage = "Please provide your gender and age.";
        }
        break;
      case 3: // Nueva página de estilo de viaje y presupuesto
        if (_selectedTravelStyle == null || _selectedBudgetTier == null) {
          _errorMessage = "Please select your travel style and budget.";
        }
        break;
      case 4: // Nueva página de fechas
        if (_tripStartDate == null || _tripEndDate == null) {
          _errorMessage = "Please select your trip dates.";
        }
        break;
    }

    if (_errorMessage != null) {
      notifyListeners();
      return;
    }

    if (_currentPage < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
    notifyListeners();
  }

  void previousPage() {
    _errorMessage = null;
    pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }

  Future<bool> finishOnboarding() async {
    if (_selectedPreferences.isEmpty) {
        _errorMessage = "Please select at least one interest.";
        notifyListeners();
        return false;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      final profileData = {
        'name': nameController.text.trim(),
        'surname': surnameController.text.trim(),
        'country': _selectedCountry!.name,
        'gender': _selectedGender,
        'age': int.tryParse(ageController.text.trim()),
        'preferences': _selectedPreferences.toList(),
        // Añadimos los nuevos datos al mapa que se envía a Supabase
        'travel_style': _selectedTravelStyle,
        'budget_tier': _selectedBudgetTier,
        'trip_start_date': _tripStartDate?.toIso8601String(),
        'trip_end_date': _tripEndDate?.toIso8601String(),
      };

      await _authService.completeOnboarding(profileData);
      _setLoading(false);
      return true;

    } catch (e) {
      _errorMessage = "An error occurred. Please try again.";
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    pageController.dispose();
    nameController.dispose();
    surnameController.dispose();
    ageController.dispose();
    super.dispose();
  }
}