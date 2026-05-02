import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/firebase_service.dart';
import 'services/blockchain_service.dart';
import 'screens/role_selector_screen.dart';
import 'screens/agent_enregistrement_screen.dart';
import 'screens/professional_access_screen.dart';
import 'screens/agent_info_screen.dart';
import 'screens/verification_screen.dart';
import 'screens/famille_screen.dart';

void main() {
  runApp(const NaissanceChainApp());
}

class NaissanceChainApp extends StatelessWidget {
  const NaissanceChainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Service Firebase pour le stockage hors-chaîne
        ChangeNotifierProvider(create: (_) => FirebaseService()),
        // Service Blockchain pour la validation
        ChangeNotifierProvider(create: (_) => BlockchainService()),
      ],
      child: MaterialApp(
        title: 'NaissanceChain',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0A1A2F),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF4F7FB),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: false,
            backgroundColor: Color(0xFFF4F7FB),
            foregroundColor: Color(0xFF0A1A2F),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            shadowColor: const Color(0xFF0A1A2F).withValues(alpha: 0.08),
            margin: EdgeInsets.zero,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              elevation: 0,
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              side: const BorderSide(color: Color(0xFFD2DAE5)),
              foregroundColor: const Color(0xFF0A1A2F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0A1A2F),
            ),
            headlineMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0A1A2F),
            ),
            titleLarge: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0A1A2F),
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Color(0xFF334155),
            ),
          ),
          dividerTheme: const DividerThemeData(
            color: Color(0xFFE1E7EF),
            thickness: 1,
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: const Color(0xFF0A1A2F),
            contentTextStyle: const TextStyle(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD5DDE8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD5DDE8)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF0A1A2F),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        // Écran d'accueil: sélection du rôle
        home: const RoleSelectorScreen(),
        // Routes utiles pour le développement et les tests
        routes: {
          '/professional-access': (context) => const ProfessionalAccessScreen(),
          '/family-access': (context) => const FamilleScreen(),
          '/agent-info': (context) => const AgentInfoScreen(),
          '/agent-enregistrement': (context) =>
              const AgentEnregistrementScreen(),
          '/verification': (context) => const VerificationScreen(),
          '/famille': (context) => const FamilleScreen(),
        },
      ),
    );
  }
}
