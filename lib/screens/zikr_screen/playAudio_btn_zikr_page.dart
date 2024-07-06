import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:yosria/audioPlayer/audioPlayer.dart';
import 'package:yosria/common/helpers/helpers.dart';
import 'package:yosria/widgets/stream_download_dialog.dart';

//
class PlayAudioBtnZikrPage extends StatelessWidget {
  const PlayAudioBtnZikrPage(
      {super.key, required this.title, required this.url});
  final String title;
  final String? url;

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
                  // TODO: change to accept value of file downloaded or not to load url or file
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
                        // return _streamOrDownloadAudioDialog(
                        //     context, url!, title);
                        return StreamOrDownloadDialog(
                            route: '/downloadManager/0',
                            toRun: () {
                              c.initPlayer(url!, title, false);
                            });
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
