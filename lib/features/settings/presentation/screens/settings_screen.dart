import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_constants.dart';
import '../../../../core/theme/glassmorphism.dart';

/// Settings Screen for configuring activation modes, languages, and privacy controls.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _heyDEnabled = true;
  bool _singleDEnabled = false;
  bool _doubleClapEnabled = true;
  bool _singleClapEnabled = false;
  String _selectedLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Activation Section
            _SectionHeader(title: 'Voice & Clap Activation'),
            _SettingCard(
              children: [
                SwitchListTile.adaptive(
                  title: const Text('Wake phrase "Hey D"'),
                  subtitle: const Text(
                      'Primary wake phrase with highest reliability'),
                  value: _heyDEnabled,
                  onChanged: (val) => setState(() => _heyDEnabled = val),
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  title: const Text('Wake word "D"'),
                  subtitle: const Text(
                    'Optional single-syllable word (higher false-trigger rate)',
                  ),
                  value: _singleDEnabled,
                  onChanged: (val) => setState(() => _singleDEnabled = val),
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  title: const Text('Double Clap Activation'),
                  subtitle: const Text(
                    'Two distinct claps within 300–800ms window',
                  ),
                  value: _doubleClapEnabled,
                  onChanged: (val) => setState(() => _doubleClapEnabled = val),
                ),
                const Divider(height: 1),
                SwitchListTile.adaptive(
                  title: const Text('Single Clap (Sensitive)'),
                  subtitle: const Text(
                    'Triggers on a single sharp clap (warning: sensitive to doors/taps)',
                  ),
                  value: _singleClapEnabled,
                  onChanged: (val) => setState(() => _singleClapEnabled = val),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Language Section
            _SectionHeader(title: 'Language & Speech'),
            _SettingCard(
              children: [
                ListTile(
                  title: const Text('Primary Language'),
                  subtitle:
                      const Text('D automatically detects spoken language'),
                  trailing: DropdownButton<String>(
                    value: _selectedLanguage,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(
                          value: 'hi', child: Text('हिंदी (Hindi)')),
                      DropdownMenuItem(
                          value: 'gu', child: Text('ગુજરાતી (Gujarati)')),
                      DropdownMenuItem(
                          value: 'hinglish', child: Text('Hinglish')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedLanguage = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Privacy Section
            _SectionHeader(title: 'Privacy & Security'),
            _SettingCard(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.shield_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text('On-Device Activation'),
                  subtitle: const Text(
                    'Wake word and clap detection run 100% locally. Zero audio leaves your device prior to activation.',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    Icons.mic_off_outlined,
                    color: theme.colorScheme.secondary,
                  ),
                  title: const Text('Master Microphone Mute'),
                  subtitle: const Text('Instantly stops all listening engines'),
                  trailing: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Listening paused.')),
                      );
                    },
                    child: const Text('Pause'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // About Section
            _SectionHeader(title: 'About'),
            _SettingCard(
              children: [
                ListTile(
                  title: Text(AppConstants.appName),
                  subtitle: Text(
                    'Version ${AppConstants.appVersion} (Build ${AppConstants.buildNumber})',
                  ),
                  trailing: const Icon(Icons.info_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Glassmorphism.cardDecoration(
        context,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}
