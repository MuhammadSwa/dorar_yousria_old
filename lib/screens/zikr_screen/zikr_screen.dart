import 'package:easy_rich_text/easy_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:yosria/models/azkar_models.dart';
import 'package:yosria/screens/settings_screen/settings_screen.dart';
import 'package:yosria/screens/zikr_screen/playAudio_btn_zikr_page.dart';

class ZikrScreen extends StatelessWidget {
  final String title;
  const ZikrScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final Zikr zikr = allAzkar.azkarCategMap[title]!;

    return Scaffold(
      appBar: AppBar(
        actions: [
          PlayAudioBtnZikrPage(
            title: zikr.title,
            url: zikr.url,
          )
        ],
        title: Text(
          title,
        ),
      ),
      body: ZikrContentWidget(
        title: zikr.title,
      ),
    );
  }
}

class ZikrContentWidget extends StatefulWidget {
  const ZikrContentWidget({super.key, required this.title});
  final String title;

  @override
  State<ZikrContentWidget> createState() => _ZikrContentWidgetState();
}

const String space = '\u0020';
const String araLettersRegex = '\u0600-\u06FF';

class _ZikrContentWidgetState extends State<ZikrContentWidget> {
  // TODO: ground settings options in one SettingsController?
  final cf = Get.put(FontController());
  @override
  Widget build(BuildContext context) {
    final Zikr zikr = allAzkar.azkarCategMap[widget.title]!;
    return GetX<FontController>(
      builder: (_) {
        return SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (zikr.notes != '') ...{
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zikr.notes,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(fontSize: cf.fontSize.value * .7),
                    ),
                    const Divider()
                  ],
                ),
              },
              EasyRichText(
                zikr.content,
                defaultStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontSize: cf.fontSize.value),
                patternList: [
                  // === footer Numbering ===

                  EasyRichTextPattern(
                    // recognizer: TapGestureRecognizer()
                    // ..onTap = () {
                    //   // TODO:scroll down to the excat footer
                    //   // first how to know the exact number?
                    //   // make me use (?) icon after the number and tap on that?,
                    //   // prefixInlineSpan: const TextSpan(text: 'down'),
                    //   // but how to know the exact number
                    //   // make in setting if to enable scroll if tapped
                    // },
                    // the line shouldn't start or end with F,X so not to interfere with rhymes matching
                    targetString: r'\[\^[0-9]+\]',

                    // r'(?<!\bF)[^\n]*\b\[\^[0-9]+\]\b',
                    // r'^[?!F].*\[\^[0-9]+\][?=.*$][?!.*X$]',
                    // r'^[?!F].*\[\^[0-9]+\][?!.*X$]',
                    // r'[^X][$F]\[\^[0-9]+\]',
                    // r'[^?!F].*[^1] .*[$?!X]',

                    // r'^(?!F)\[\^[0-9]+\]$(?!X)',

                    matchBuilder: (context, match) {
                      final text = match?[0]?.replaceAll('^', '');
                      // TODO: make it 50% transparent?
                      // better styling
                      return TextSpan(
                        text: text,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(fontSize: cf.fontSize.value * .7),
                      );
                    },
                  ),

                  // === quarn verses and hadith ===

                  EasyRichTextPattern(
                    targetString: [
                      '«[^»]+»',
                    ],
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                  ),
                  EasyRichTextPattern(
                    targetString: [
                      r'﴿[^﴾]+﴾',
                      '«[^»]+»',
                      'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ'
                    ],
                    style: TextStyle(
                      fontFamily: "AmiriQuran",
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                    ),
                  ),

                  // TODO: better patternt matching and beter replacing.
                  EasyRichTextPattern(
                    targetString:
                        // r'^F([^X]*)X',
                        // matchRightWordBoundary: true,
                        r'F[^X][\u0600-\u06FF\s0-9\[\]\^]+__[\u0600-\u06FF\s0-9\[\]\^]+X',
                    //  r'F(?!X)[\u0600-\u06FF\s0-9\[\]\^]+__[\u0600-\u06FF\s0-9\[\]\^]+X',
                    // targetString: '.*:FF:.*',
                    matchBuilder: (context, match) {
                      final rhymes = match?[0]!
                          .replaceAll('F', '')
                          .replaceAll('X', '')
                          .split('__');
                      return TextSpan(
                        children: [
                          WidgetSpan(
                            child: RhymesWidget(
                                first: rhymes![0], second: rhymes[1]),
                          ),
                        ],
                      );
                    },
                    style: const TextStyle(color: Colors.green),
                  ),

                  EasyRichTextPattern(
                    targetString: r'[0-9/]*\.',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(fontSize: cf.fontSize.value),
                  ),
                  EasyRichTextPattern(
                    targetString: [
                      r'\[[\u0600-\u06FF\s]+:[^\]]+[0-9]\]',
                      r'\[تقرأ مرة واحدة للمتعجل\]',
                      // r'\(سبع مرات\)',
                      // r'\(ثلاثًا\)',
                    ],
                    // style: Theme.of(context).textTheme.labelSmall!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(fontSize: cf.fontSize.value * .7),
                    // style: TextStyle(color: Colors.green),
                  ),

                  // TODO: Theme:
                  EasyRichTextPattern(
                    targetString: '##[$araLettersRegex$space()ﷺ]+',
                    matchBuilder: (context, match) {
                      final text = match?[0]?.replaceAll('##', '');
                      // TODO: Theme
                      return TextSpan(
                        text: text,
                        // TODO: theme
                        // font from shared_prefs
                        style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall!.color,
                            fontSize: 26),
                      );
                    },
                  )
                ],
                textAlign: TextAlign.justify,
              ),
              if (zikr.footer != '') ...{
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    Text(
                      zikr.footer,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(fontSize: cf.fontSize.value * .7),
                    ),
                  ],
                ),
              }
            ],
          ),
        ));
      },
    );
  }
}

class RhymesWidget extends StatelessWidget {
  const RhymesWidget({super.key, required this.first, required this.second});
  final String first, second;
  EasyRichTextPattern _buildPattern() {
    final cf = Get.put(FontController());
    return EasyRichTextPattern(
      targetString: r'\[\^\^[0-9]+\]',
      matchBuilder: (context, match) {
        final text = match?[0]?.replaceAll('^', '');
        // TODO: make it 50% transparent?
        // better styling
        return TextSpan(
          text: text,
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(fontSize: cf.fontSize.value * .7),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        // alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: EasyRichText(
              first,
              textAlign: TextAlign.right,
              patternList: [_buildPattern()],
            ),
          ),
          Align(
              alignment: Alignment.centerLeft,
              child: EasyRichText(second,
                  patternList: [_buildPattern()], textAlign: TextAlign.left))
          // const Text(':\n',
          //     textAlign: TextAlign.right),
        ],
      ),
    );
  }
}
