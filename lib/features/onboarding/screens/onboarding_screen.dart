import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:country_picker/country_picker.dart';
import 'package:intl/intl.dart';
import '../../map/map_screen.dart';
import '../viewmodel/onboarding_viewmodel.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _navigateToMapScreen(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MapScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingViewModel(),
      child: Consumer<OnboardingViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.state == OnboardingState.loading) {
            return const Scaffold(
              backgroundColor: Color(0xFF121212),
              body: Center(
                child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 29, 168, 64),
                ),
              ),
            );
          }
          return Scaffold(
            backgroundColor: const Color(0xFF121212),
            body: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/login_background.jpg'),
                      fit: BoxFit.cover,
                      opacity: 0.2,
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _OnboardingHeader(
                          currentPage: viewModel.currentPage,
                          totalPages: viewModel.totalPages,
                        ),
                        Expanded(
                          child: PageView(
                            controller: viewModel.pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              _OnboardingStep(
                                icon: Icons.person_outline,
                                title: "What's your name?",
                                child: _buildNameStep(viewModel),
                              ),
                              _OnboardingStep(
                                icon: Icons.public_outlined,
                                title: "Where are you from?",
                                child: _buildCountryStep(context, viewModel),
                              ),
                              _OnboardingStep(
                                icon: Icons.wc_outlined,
                                title: "A bit more about you",
                                child: _buildDemographicsStep(viewModel),
                              ),
                              // --- NUEVAS PÁGINAS ---
                              _OnboardingStep(
                                icon: Icons.card_travel,
                                title: "How do you travel?",
                                subtitle: "Tell us about your trip style.",
                                child: _buildTravelStyleStep(viewModel),
                              ),
                              _OnboardingStep(
                                icon: Icons.date_range_outlined,
                                title: "When are you visiting?",
                                child: _buildTripDatesStep(context, viewModel),
                              ),
                              // --- FIN DE NUEVAS PÁGINAS ---
                              _OnboardingStep(
                                icon: Icons.interests_outlined,
                                title: "What do you like?",
                                subtitle: "Select your interests for personalized tips.",
                                child: _buildPreferencesStep(viewModel),
                              ),
                            ],
                          ),
                        ),
                        _buildNavigationControls(context, viewModel),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGETS DE LOS PASOS ---

  Widget _buildNameStep(OnboardingViewModel viewModel) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTextField(hintText: "Name", controller: viewModel.nameController),
        const SizedBox(height: 20),
        _buildTextField(hintText: "Surname", controller: viewModel.surnameController),
      ],
    );
  }

  Widget _buildCountryStep(BuildContext context, OnboardingViewModel viewModel) {
    return _buildPickerButton(
      context: context,
      value: viewModel.selectedCountry?.name,
      hint: "Select your country",
      icon: viewModel.selectedCountry != null 
          ? Text(viewModel.selectedCountry!.flagEmoji, style: const TextStyle(fontSize: 24))
          : null,
      onTap: () {
        showCountryPicker(
          context: context,
          countryListTheme: CountryListThemeData(
            backgroundColor: const Color(0xFF1E1E1E),
            textStyle: const TextStyle(color: Colors.white),
            inputDecoration: InputDecoration(
              labelText: 'Search', hintText: 'Start typing to search',
              labelStyle: const TextStyle(color: Colors.white70),
              hintStyle: const TextStyle(color: Colors.white38),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
            ),
          ),
          onSelect: (Country country) => viewModel.selectCountry(country),
        );
      },
    );
  }

  Widget _buildDemographicsStep(OnboardingViewModel viewModel) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTextField(
            hintText: "Age",
            controller: viewModel.ageController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          children: viewModel.availableGenders.map((gender) {
            final isSelected = viewModel.selectedGender == gender;
            return ChoiceChip(
              label: Text(gender),
              selected: isSelected,
              onSelected: (_) => viewModel.selectGender(gender),
              backgroundColor: Colors.black.withOpacity(0.3),
              labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
              selectedColor: Colors.white,
            );
          }).toList(),
        )
      ],
    );
  }

  // --- NUEVOS WIDGETS DE PASOS ---
  Widget _buildTravelStyleStep(OnboardingViewModel viewModel) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("I'm travelling...", style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: viewModel.availableTravelStyles.map((style) {
            final isSelected = viewModel.selectedTravelStyle == style;
            return ChoiceChip(
              label: Text(style),
              selected: isSelected,
              onSelected: (_) => viewModel.selectTravelStyle(style),
              backgroundColor: Colors.black.withOpacity(0.3),
              labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
              selectedColor: Colors.white,
            );
          }).toList(),
        ),
        const SizedBox(height: 30),
        const Text("My budget is...", style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: viewModel.availableBudgetTiers.map((tier) {
            final isSelected = viewModel.selectedBudgetTier == tier;
            return ChoiceChip(
              label: Text(tier),
              selected: isSelected,
              onSelected: (_) => viewModel.selectBudgetTier(tier),
              backgroundColor: Colors.black.withOpacity(0.3),
              labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
              selectedColor: Colors.white,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTripDatesStep(BuildContext context, OnboardingViewModel viewModel) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final String buttonText = viewModel.tripStartDate != null && viewModel.tripEndDate != null
      ? "${dateFormat.format(viewModel.tripStartDate!)} - ${dateFormat.format(viewModel.tripEndDate!)}"
      : "Select your trip dates";

    return _buildPickerButton(
      context: context,
      value: viewModel.tripStartDate != null ? buttonText : null,
      hint: "Select your trip dates",
      onTap: () async {
        final dateRange = await showDateRangePicker(
          context: context,
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
          builder: (context, child) {
            return Theme(
              data: ThemeData.dark().copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: Color.fromARGB(255, 29, 168, 64),
                  onPrimary: Colors.white,
                  surface: Color(0xFF1E1E1E),
                  onSurface: Colors.white,
                ), dialogTheme: DialogThemeData(backgroundColor: const Color(0xFF121212)),
              ),
              child: child!,
            );
          },
        );
        if (dateRange != null) {
          viewModel.setTripDates(dateRange.start, dateRange.end);
        }
      },
    );
  }
  // --- FIN DE NUEVOS WIDGETS ---

  Widget _buildPreferencesStep(OnboardingViewModel viewModel) {
    return Center(
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 12.0, runSpacing: 12.0, alignment: WrapAlignment.center,
          children: viewModel.availablePreferences.map((preference) {
            final isSelected = viewModel.selectedPreferences.contains(preference);
            return FilterChip(
              label: Text(preference),
              selected: isSelected,
              onSelected: (_) => viewModel.togglePreference(preference),
              backgroundColor: Colors.black.withOpacity(0.3),
              labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold),
              selectedColor: Colors.white,
              checkmarkColor: Colors.black,
              shape: StadiumBorder(side: BorderSide(color: isSelected ? Colors.white : Colors.white54)),
            );
          }).toList(),
        ),
      ),
    );
  }

  // --- WIDGETS REUTILIZABLES Y DE NAVEGACIÓN ---
  Widget _buildNavigationControls(BuildContext context, OnboardingViewModel viewModel) {
    return Column(
      children: [
        if (viewModel.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(viewModel.errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 12), textAlign: TextAlign.center),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Opacity(
              opacity: viewModel.currentPage > 0 ? 1.0 : 0.0,
              child: IconButton(
                onPressed: viewModel.currentPage > 0 ? viewModel.previousPage : null,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (viewModel.currentPage < viewModel.totalPages - 1) {
                  viewModel.nextPage();
                } else {
                  if (await viewModel.finishOnboarding()) {
                    _navigateToMapScreen(context);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 29, 168, 64),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: viewModel.isLoading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(
                      viewModel.currentPage < viewModel.totalPages - 1 ? "Next" : "Finish",
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
            Opacity(
              opacity: 0,
              child: IconButton(onPressed: null, icon: const Icon(Icons.arrow_back)),
            ),
          ],
        ),
        TextButton(
          onPressed: () => _navigateToMapScreen(context),
          child: const Text("Skip for now", style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
  
  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromARGB(255, 29, 168, 64)),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    );
  }

  Widget _buildPickerButton({
    required BuildContext context,
    required String? value,
    required String hint,
    required VoidCallback onTap,
    Widget? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            if (icon != null) ...[icon, const SizedBox(width: 15)],
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(
                  color: value != null ? Colors.white : Colors.grey.shade400,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS AUXILIARES ---
class _OnboardingHeader extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  const _OnboardingHeader({required this.currentPage, required this.totalPages});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        return Flexible(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 5,
            decoration: BoxDecoration(
              color: currentPage >= index
                  ? const Color.fromARGB(255, 29, 168, 64)
                  : Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }),
    );
  }
}

class _OnboardingStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;

  const _OnboardingStep({required this.icon, required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 2),
        Icon(icon, size: 40, color: Colors.white.withOpacity(0.8)),
        const SizedBox(height: 20),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        if (subtitle != null) ...[
          const SizedBox(height: 10),
          Text(subtitle!, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
        ],
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: child,
        ),
        const Spacer(flex: 3),
      ],
    );
  }
}