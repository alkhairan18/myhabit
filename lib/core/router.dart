import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/habits/presentation/archive_screen.dart';
import '../features/habits/presentation/habit_form_screen.dart';
import '../features/habits/presentation/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) => GoRouter(routes: [
      GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
      GoRoute(path: '/habit/new', builder: (_, _) => const HabitFormScreen()),
      GoRoute(
        path: '/habit/:id/edit',
        builder: (_, s) => HabitFormScreen(habitId: int.parse(s.pathParameters['id']!)),
      ),
      GoRoute(path: '/archive', builder: (_, _) => const ArchiveScreen()),
    ]));
