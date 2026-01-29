import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants.dart';
import 'core/utils/router_stream.dart'; // Asegúrate de tener este archivo del paso anterior
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/trips/presentation/pages/home_page.dart';
import 'features/trips/presentation/pages/trip_details_page.dart';
import 'features/trips/data/models/trip_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el estado de autenticación
    final authState = ref.watch(authStateProvider);

    final router = GoRouter(
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(authState.stream),
      redirect: (context, state) {
        final session = Supabase.instance.client.auth.currentSession;
        final loggingIn = state.uri.toString() == '/login';
        final registering = state.uri.toString() == '/register';

        // Si no hay sesión y no estamos en login/registro -> Login
        if (session == null) {
          if (!loggingIn && !registering) return '/login';
        }

        // Si hay sesión y estamos en login/registro -> Home
        if (session != null) {
          if (loggingIn || registering) return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/trip-details',
          builder: (context, state) {
            final trip = state.extra as TripModel;
            return TripDetailsPage(trip: trip);
          },
        ),
      ],
    );

    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF006994),
      primary: const Color(0xFF006994),
      secondary: const Color(0xFF40E0D0),
      brightness: Brightness.light,
    );

    final textTheme = GoogleFonts.poppinsTextTheme();

    return MaterialApp.router(
      title: 'AquaRuta',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        colorScheme: colorScheme,
        textTheme: textTheme,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}