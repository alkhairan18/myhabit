import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/habits/presentation/home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) => GoRouter(routes: [
      GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
    ]));
