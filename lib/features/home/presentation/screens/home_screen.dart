import 'package:artifex/features/home/presentation/widgets/image_input_section.dart';
import 'package:artifex/features/home/presentation/widgets/welcome_section.dart';
import 'package:artifex/features/settings/presentation/screens/settings_screen.dart';
import 'package:artifex/shared/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    backgroundColor: AppTheme.colors.background,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Settings button at top right
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const SettingsScreen(),
                    ),
                  ),
                  icon: Icon(
                    Icons.settings,
                    color: AppTheme.colors.onBackground,
                  ),
                  iconSize: 28,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const WelcomeSection(),
            const SizedBox(height: 40),
            const Expanded(child: ImageInputSection()),
          ],
        ),
      ),
    ),
  );
}
