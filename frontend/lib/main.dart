import 'package:flutter/material.dart';
// import 'package:user_registration/screens/auth/login_screen.dart';
// import 'register_screen.dart';
import 'package:travelowkey/app_router.dart';
import 'package:provider/provider.dart';
import 'package:travelowkey/services/api_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:intl/intl.dart'; // For intl support

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('recommendationBox');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUserInfo()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // locale: Locale('vi', 'VN'), // Set the default locale to Vietnamese
      // supportedLocales: [
      //   Locale('en', 'US'), // English locale
      //   Locale('vi', 'VN'), // Vietnamese locale
      // ],
      // localizationsDelegates: [
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      title: 'travelowkey',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
