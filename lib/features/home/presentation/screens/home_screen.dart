import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/glassmorphism.dart';

/// Main Home / Dashboard screen showing assistant status and quick activations.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appName),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go(AppRoutes.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Assistant Hero Orb Card
              _AssistantHeroCard(),
              const SizedBox(height: 20),

              // Activation Modes Status
              Text(
                'Activation Modes',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _ActivationModeTile(
                icon: Icons.mic_rounded,
                title: 'Wake Phrase: "${AppConstants.wakePhraseHeyD}"',
                subtitle: 'Always active on-device',
                isActive: true,
              ),
              const SizedBox(height: 8),
              _ActivationModeTile(
                icon: Icons.graphic_eq_rounded,
                title: 'Double Clap Detection',
                subtitle: 'Two claps within 300–800ms',
                isActive: true,
              ),
              const SizedBox(height: 8),
              _ActivationModeTile(
                icon: Icons.record_voice_over_rounded,
                title: 'Wake Word: "${AppConstants.wakeWordD}"',
                subtitle: 'Optional single-syllable (lower sensitivity)',
                isActive: false,
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Chat',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.chat),
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                label: const Text('Open Conversation'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssistantHeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: Glassmorphism.cardDecoration(
        context,
        tintColor: theme.colorScheme.primary,
        opacity: 0.12,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // Glowing Orb Placeholder
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.8),
                  theme.colorScheme.secondary.withOpacity(0.4),
                  Colors.transparent,
                ],
                stops: const [0.2, 0.6, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Text(
                AppConstants.appName,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Ready to assist you',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Say "Hey ${AppConstants.appName}" or clap twice',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivationModeTile extends StatelessWidget {
  const _ActivationModeTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isActive,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: Glassmorphism.cardDecoration(
        context,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primary.withOpacity(0.15)
                  : theme.colorScheme.surfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isActive ? 'ON' : 'OFF',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

