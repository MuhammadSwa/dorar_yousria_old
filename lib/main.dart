import 'dart:ui';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:provider/provider.dart';
import 'package:yosria/common/theme/dark_theme.dart';
import 'package:yosria/router/handle_router.dart';
import 'package:yosria/screens/download_manager_screen/download_controller.dart';
import 'package:yosria/services/providers.dart';
import 'package:yosria/services/shared_prefs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesService().init();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  Get.put(DownloaderController());
  runApp(
    MyApp(theme: savedThemeMode),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.theme});
  final AdaptiveThemeMode? theme;

  final _router = handleRouter();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CoordinatesProvider>(
          create: (context) => CoordinatesProvider(),
        ),
      ],
      child: AdaptiveTheme(
        light: lightTheme,
        dark: darkTheme,
        // initial: AdaptiveThemeMode.dark,
        initial: theme ?? AdaptiveThemeMode.system,
// ,
        builder: (theme, darkTheme) => MaterialApp.router(
          scrollBehavior: AppScrollBehavior(),
          routerConfig: _router,
          title: 'الطريقة اليسرية',
          debugShowCheckedModeBanner: false,
          darkTheme: darkTheme,
          theme: theme,
        ),
      ),
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
