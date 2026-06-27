import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/fortlock_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_colors.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FortlockApp());
}

class FortlockApp extends StatelessWidget {
  const FortlockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FortlockProvider(),
      child: MaterialApp(
        title: 'Fortlock',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.offWhite,
          fontFamily: 'Roboto',
          colorScheme: ColorScheme.light(
            primary: AppColors.darkBlue,
            secondary: AppColors.primaryBlue,
            surface: AppColors.white,
          ),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
