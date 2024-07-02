import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:yosria/screens/settings_screen/toggleThemeBtn_widget.dart';
import 'package:yosria/screens/settings_screen/yousriaBeginningDayDropdown_widget.dart';
import 'package:yosria/services/shared_prefs.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(FontController());
    // TODO: make widget for each settings category?
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإعدادات'),
        ),
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'المظهر',
                    // TODO: change using font theme
                    style: TextStyle(fontSize: 20),
                  ),
                  ToggleThemeBtn()
                ],
              ),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'بداية الصلوات اليسرية',
                    // TODO: change using font theme
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  YousriaBeginningDayDropDown()
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'حجم الخط',
                    // TODO: change using font theme
                    style: TextStyle(fontSize: 20),
                  ),
                  IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text(
                                  'حجم الخط',
                                  textAlign: TextAlign.center,
                                ),
                                content: SizedBox(
                                  height: 80,
                                  child: Obx(
                                    () {
                                      return Slider(
                                        label:
                                            c.fontSize.value.round().toString(),
                                        divisions: 15,
                                        min: 16,
                                        max: 40,
                                        value: c.fontSize.value,
                                        onChanged: c.changeSize,
                                      );
                                    },
                                  ),
                                ),
                              );
                            });
                      },
                      icon: const Icon(Icons.format_size))
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'إدارة التحميلات',
                    // TODO: change using font theme
                    style: TextStyle(fontSize: 20),
                  ),
                  IconButton(
                      onPressed: () {
                      context.push('/downloadManager/0');
                      },
                      icon: const Icon(Icons.cloud_download_outlined))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//

class FontController extends GetxController {
  var fontSize = SharedPreferencesService.getFontSize().obs;
  changeSize(double newSize) {
    fontSize.value = newSize;
    SharedPreferencesService.setFontSize(newSize);
  }
}
