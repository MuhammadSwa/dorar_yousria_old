import 'dart:ui';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:yosria/common/theme/dark_theme.dart';
import 'package:yosria/router/handle_router.dart';
import 'package:yosria/screens/download_manager_screen/download_controller.dart';
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
    return AdaptiveTheme(
      light: lightTheme,
      dark: darkTheme,
      initial: theme ?? AdaptiveThemeMode.system,
      // TODO: change routing to Getx
      builder: (theme, darkTheme) => MaterialApp.router(
        routerConfig: _router,
        scrollBehavior: AppScrollBehavior(),
        title: 'الطريقة اليسرية',
        debugShowCheckedModeBanner: false,
        darkTheme: darkTheme,
        theme: theme,
      ),
      // ),
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
