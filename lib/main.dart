import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/colors.dart';
import 'core/network/pocketbase_client.dart';
import 'core/navigation/navigation_service.dart';
import 'features/dashboard/screens/main_hub_navigation.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PocketBaseService()),
        ChangeNotifierProvider(create: (_) => NavigationService()),
      ],
      child: const Kreyol360App(),
    ),
  );
}

class Kreyol360App extends StatelessWidget {
  const Kreyol360App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kréyol360 Immersive Experience',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          background: AppColors.background,
          onBackground: AppColors.onBackground,
          onSurface: AppColors.onSurface,
        ),
        textTheme: GoogleFonts.beVietnamProTextTheme(
          ThemeData.dark().textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.epilogue(
            textStyle: ThemeData.dark().textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
          ),
          headlineMedium: GoogleFonts.epilogue(
            textStyle: ThemeData.dark().textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
          ),
        ),
      ),
      home: const MainHubNavigation(),
    );
  }
}
