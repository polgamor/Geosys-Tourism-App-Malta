import 'package:flutter/material.dart';
import 'package:geosys_app/localization/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:geosys_app/localization/locale_provider.dart';

class LanguagePickerWidget extends StatelessWidget {
  const LanguagePickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LocaleProvider>(context, listen: false);

    return IconButton(
      icon: const Icon(Icons.language, color: Colors.white, size: 28),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: Text(
              AppLocalizations.of(context)!.selectLanguage,
              style: const TextStyle(color: Colors.white)
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguageTile(context, provider, 'English', const Locale('en')),
                _buildLanguageTile(context, provider, 'Español', const Locale('es')),
                _buildLanguageTile(context, provider, 'Français', const Locale('fr')),
                _buildLanguageTile(context, provider, 'Italiano', const Locale('it')),
                _buildLanguageTile(context, provider, 'Deutsch', const Locale('de')), 
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageTile(BuildContext context, LocaleProvider provider, String language, Locale locale) {
    return ListTile(
      title: Text(language, style: const TextStyle(color: Colors.white)),
      onTap: () {
        provider.setLocale(locale);
        Navigator.of(context).pop();
      },
    );
  }
}