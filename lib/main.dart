import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants.dart';
import 'core/utils/router_stream.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/trips/data/models/trip_model.dart';
import 'features/trips/presentation/pages/home_page.dart';
import 'features/trips/presentation/pages/trip_details_page.dart';

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
    final authAsync = ref.watch(authStateProvider);
    final user = authAsync.value;

    final router = GoRouter(
      initialLocation: '/',
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
            final extra = state.extra;
            if (extra is! TripModel) {
              return const HomePage();
            }
            return TripDetailsPage(trip: extra);
          },
        ),
      ],
      redirect: (context, state) {
        final location = state.uri.toString();
        final loggingIn = location == '/login';
        final registering = location == '/register';

        // Mientras el estado de auth está cargando, no redirigir.
        if (authAsync.isLoading) {
          return null;
        }

        if (user == null) {
          // No autenticado: solo permitir login y register.
          if (!loggingIn && !registering) {
            return '/login';
          }
          return null;
        }

        // Autenticado: evitar login/register.
        if (loggingIn || registering) {
          return '/';
        }

        return null;
      },
      refreshListenable:
          GoRouterRefreshStream(ref.watch(authStateProvider.stream)),
    );

    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF006994),
      primary: const Color(0xFF006994), // Azul Oc1ano
      secondary: const Color(0xFF40E0D0), // Turquesa
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
        appBarTheme: AppBarTheme(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: colorScheme.secondary,
          foregroundColor: Colors.black,
        ),
      ),
    );
  }
}
