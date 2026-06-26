import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/fortlock_provider.dart';
import 'screens/home_shell.dart';
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
          scaffoldBackgroundColor: const Color(0xFF050A14),
          fontFamily: 'Roboto',
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFF00D4FF),
            secondary: const Color(0xFF1E6FD9),
            surface: const Color(0xFF0B1524),
          ),
          useMaterial3: true,
        ),
        home: const HomeShell(),
      ),
    );
  }
}
