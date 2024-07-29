import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:infinite_tic_tac_toe/controller.dart';
import 'package:infinite_tic_tac_toe/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Get.lazyPut(() => AppController());
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Infinite Tic Tac Toe',
      theme: ThemeData(
          brightness: Brightness.light,
          useMaterial3: true,
          fontFamily: 'Montserrat'),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          fontFamily: 'Montserrat'),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      getPages: appRoutes,
    );
  }
}
