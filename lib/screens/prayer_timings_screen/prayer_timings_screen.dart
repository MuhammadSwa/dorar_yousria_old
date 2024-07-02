import 'dart:async';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';
import 'package:yosria/screens/prayer_timings_screen/adjust_hijri_day_dialogBox.dart';
import 'package:yosria/screens/prayer_timings_screen/location_button_widget.dart';
import 'package:yosria/screens/prayer_timings_screen/manual_coordination_form.dart';
import 'package:yosria/services/providers.dart';
import 'package:yosria/screens/prayer_timings_screen/hijri_date_widget.dart';

class PrayerTimingsScreen extends StatelessWidget {
  const PrayerTimingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('مواقيت الصلاة'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // this should be on dialog (adjust hijri date.).confirm btn
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (builder) => ManualCoordinatesForm());
                    },
                    label: const Text('إعدادات المواقيت'),
                    icon: const Icon(Icons.settings),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (builder) {
                            return const AdjustHijriDayDialogbox();
                          });
                    },
                    label: const Text('تعديل اليوم الهجرى'),
                    icon: const Icon(Icons.date_range),
                  ),
                ],
              ),
              const SizedBox(height: 10),
//
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NextPrayerWidget(),
//
                  HijriDateWidget(),
                ],
              ),
//
              const PrayerTimingsWidget(),
            ],
          ),
        ));
  }
}

class NextPrayerWidget extends StatefulWidget {
  const NextPrayerWidget({
    super.key,
  });

  @override
  State<NextPrayerWidget> createState() => _NextPrayerWidgetState();
}

class _NextPrayerWidgetState extends State<NextPrayerWidget> {
  late Timer timer;

  late Duration timeLeft = PrayerTimeings.timeLeftForNextPrayer().$1;
  final prayerName = PrayerTimeings.timeLeftForNextPrayer().$2;

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    // timer = Timer.periodic(
    //   const Duration(seconds: 1),
    //   (_) {
    //     setState(() {
    //       timeLeft = PrayerTimeings.timeLeftForNextPrayer();
    //     });
    //   },
    // );
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        setState(() {
          if (timeLeft.inSeconds == 0) {
            timeLeft = PrayerTimeings.timeLeftForNextPrayer().$1;
          } else {
            timeLeft = timeLeft - const Duration(seconds: 1);
          }
        });
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$prayerName بعد ${timeLeft.toString().split('.').first}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }
}

class PrayerTimingsWidget extends StatelessWidget {
  const PrayerTimingsWidget({super.key});
  static late PrayerTimes? prayerTimes;

  TableRow _buildTableRow(String name, DateTime? time) {
    late final String period;
    late final intl.DateFormat customFormat;
    if (time != null) {
      period = (time.hour >= 12) ? 'م' : 'ص';
      customFormat = intl.DateFormat('hh:mm $period', 'en_US');
    }

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(name, style: const TextStyle(fontSize: 16)),
        ),
        if (time == null) ...{
          const Text('00:00', style: TextStyle(fontSize: 16)),
        } else ...{
          Text(
            customFormat.format(time),
            style: const TextStyle(fontSize: 16),
          )
        },
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    prayerTimes = context.watch<CoordinatesProvider>().getPrayersTimings();
    SunnahTimes? sunnahTimes;
    if (prayerTimes != null) {
      sunnahTimes = SunnahTimes(prayerTimes!);
    }
    final duha = prayerTimes?.sunrise.add(const Duration(minutes: 20));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        if (prayerTimes == null) ...{
          Text(
            'برجاء تحديد الموقع',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        } else ...{
          Text(
            'مواقيت الصلاة',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        },
        const SizedBox(height: 10),
        Table(
          columnWidths: {
            0: FixedColumnWidth(MediaQuery.of(context).size.width / 3),
            1: FixedColumnWidth(MediaQuery.of(context).size.width / 3)
          },
          border: TableBorder(
            horizontalInside: BorderSide(
                width: 1, color: Theme.of(context).colorScheme.secondaryFixed),
          ),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            _buildTableRow('المغرب', prayerTimes?.maghrib),
            _buildTableRow('العشاء', prayerTimes?.isha),
            _buildTableRow('منتصف الليل', sunnahTimes?.middleOfTheNight),
            _buildTableRow('الثلث الأخير', sunnahTimes?.lastThirdOfTheNight),
            _buildTableRow('الفجر', prayerTimes?.fajr),
            _buildTableRow('الشروق', prayerTimes?.sunrise),
            _buildTableRow('الضحى', duha),
            _buildTableRow('الظهر', prayerTimes?.dhuhr),
            _buildTableRow('العصر', prayerTimes?.asr),
          ],
        ),
      ],
    );
  }
}
