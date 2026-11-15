import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/habits/application/providers.dart';
import '../features/habits/presentation/archive_screen.dart';
import '../features/habits/presentation/habit_detail_screen.dart';
import '../features/habits/presentation/habit_form_screen.dart';
import '../features/habits/presentation/home_screen.dart';
import '../features/settings/onboarding_screen.dart';
import '../features/settings/settings_screen.dart';

int _id(GoRouterState s) => int.tryParse(s.pathParameters['id'] ?? '') ?? -1;

final routerProvider = Provider<GoRouter>((ref) => GoRouter(
      redirect: (_, state) {
        final done = ref.read(settingsRepositoryProvider).onboardingDone;
        if (!done && state.matchedLocation != '/onboarding') {
          return '/onboarding';
        }
        return null;
      },
      routes: [
        GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
        GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
        GoRoute(path: '/habit/new', builder: (_, _) => const HabitFormScreen()),
        GoRoute(path: '/habit/:id', builder: (_, s) => HabitDetailScreen(habitId: _id(s))),
        GoRoute(path: '/habit/:id/edit', builder: (_, s) => HabitFormScreen(habitId: _id(s))),
        GoRoute(path: '/archive', builder: (_, _) => const ArchiveScreen()),
        GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      ],
    ));
