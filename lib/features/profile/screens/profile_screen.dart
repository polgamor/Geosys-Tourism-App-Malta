import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'edit_profile_screen.dart';
import '../viewmodel/profile_viewmodel.dart';
import '../../login/screens/login_screen.dart';
import '../../widgets/language_picker_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/login_background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(color: Colors.black.withOpacity(0.75)),
            const _ProfileContentView(),
          ],
        ),
      ),
    );
  }
}

class _ProfileContentView extends StatelessWidget {
  const _ProfileContentView();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          const LanguagePickerWidget(),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            tooltip: 'Sign Out',
            onPressed: () async {
              await viewModel.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (viewModel.isLoading && viewModel.profileData == null) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          if (viewModel.profileData == null) {
            return const Center(
              child: Text('Could not load profile.', style: TextStyle(color: Colors.white70)),
            );
          }

          final profile = viewModel.profileData!;
          final age = profile['age']?.toString() ?? '';
          final name = profile['name'] ?? 'No Name';
          final title = age.isNotEmpty ? '$name, $age' : name;

          return RefreshIndicator(
            onRefresh: viewModel.loadProfile,
            color: Colors.white,
            backgroundColor: const Color.fromARGB(255, 29, 168, 64),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildAvatar(profile['avatar_url']),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '@${profile['username']}',
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  _buildEditProfileButton(context, viewModel),
                  const SizedBox(height: 32),
                  _InfoCard(
                    title: 'About Me',
                    children: [
                      _InfoRow(
                        icon: Icons.public_outlined,
                        text: profile['country'] ?? 'Not provided',
                      ),
                      _InfoRow(
                        icon: Icons.wc_outlined,
                        text: profile['gender'] ?? 'Not provided',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _InfoCard(
                    title: 'My Trip',
                    children: [
                      _InfoRow(
                        icon: Icons.date_range_outlined,
                        text: _formatTripDates(profile),
                      ),
                      _InfoRow(
                        icon: Icons.card_travel_outlined,
                        text: profile['travel_style'] ?? 'Not provided',
                      ),
                      _InfoRow(
                        icon: Icons.wallet_outlined,
                        text: profile['budget_tier'] ?? 'Not provided',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInterestsCard(profile['preferences']),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatTripDates(Map<String, dynamic> profile) {
    final startDateStr = profile['trip_start_date'];
    final endDateStr = profile['trip_end_date'];
    if (startDateStr == null || endDateStr == null) return 'Not provided';
    try {
      final dateFormat = DateFormat('MMM d, yyyy');
      final startDate = dateFormat.format(DateTime.parse(startDateStr));
      final endDate = dateFormat.format(DateTime.parse(endDateStr));
      return '$startDate - $endDate';
    } catch (_) {
      return 'Invalid date format';
    }
  }

  Widget _buildAvatar(String? avatarUrl) {
    return CircleAvatar(
      radius: 64,
      backgroundColor: Colors.white.withOpacity(0.3),
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.black.withOpacity(0.5),
        backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
            ? CachedNetworkImageProvider(avatarUrl)
            : null,
        child: (avatarUrl == null || avatarUrl.isEmpty)
            ? const Icon(Icons.person, size: 60, color: Colors.white70)
            : null,
      ),
    );
  }

  Widget _buildEditProfileButton(BuildContext context, ProfileViewModel viewModel) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.edit, size: 18, color: Colors.white),
        label: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: viewModel,
              child: const EditProfileScreen(),
            ),
          ));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.15),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          side: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
      ),
    );
  }

  Widget _buildInterestsCard(dynamic preferencesData) {
    if (preferencesData == null || (preferencesData as List).isEmpty) {
      return const SizedBox.shrink();
    }
    final preferences = preferencesData.map((p) => p.toString()).toList();

    return _InfoCard(
      title: 'Interests',
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          spacing: 10.0,
          runSpacing: 10.0,
          alignment: WrapAlignment.center,
          children: preferences
              .map(
                (p) => Chip(
                  label: Text(
                    p,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: const Color.fromARGB(255, 29, 168, 64).withOpacity(0.8),
                  side: BorderSide.none,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final CrossAxisAlignment? crossAxisAlignment;

  const _InfoCard({
    required this.title,
    required this.children,
    this.crossAxisAlignment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
