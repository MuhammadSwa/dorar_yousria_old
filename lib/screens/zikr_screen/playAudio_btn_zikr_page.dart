import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:yosria/audioPlayer/audioPlayer.dart';
import 'package:go_router/go_router.dart';
import 'package:yosria/common/helpers/helpers.dart';

class PlayAudioBtnZikrPage extends StatelessWidget {
  const PlayAudioBtnZikrPage(
      {super.key, required this.title, required this.url});
  final String title;
  final String? url;

  Widget _streamOrDownloadAudioDialog(
      BuildContext context, String url, String title) {
    final c = Get.put(Controller());
    return AlertDialog(
      contentPadding: const EdgeInsets.all(20),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              context.push('/downloadManager/0');
            },
            label: const Text('تحميل'),
            icon: const Icon(Icons.download),
          ),
          const SizedBox(width: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              c.initPlayer(url, title, false);
            },
            label: const Text('تشغيل بالإنترنت'),
            icon: const Icon(Icons.settings_input_antenna),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.put(Controller());

    return FutureBuilder(
      future: isFileDownloaded(title: title, directory: 'narrations'),
      builder: (context, snapshot) {
        // if file exists, just play the file
        return Obx(() {
          if (c.url.value != url && url != null) {
            if (snapshot.data == true) {
              return IconButton(
                onPressed: () {
                  c.initPlayer(url!, title, true);
                },
                icon: const Icon(Icons.volume_up),
              );
            } // if file doesn't exist, ask t he user to choose between streaming or downloading it
            else {
              return IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return _streamOrDownloadAudioDialog(
                            context, url!, title);
                      },
                    );
                  },
                  icon: const Icon(Icons.volume_up));
            }
          } else {
            return Container();
          }
        });
      },
    );
  }
}
