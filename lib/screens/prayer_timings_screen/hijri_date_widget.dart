import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:yosria/screens/prayer_timings_screen/adjust_hijri_day_dialogBox.dart';
import 'package:yosria/services/providers.dart';

class HijriDateWidget extends StatefulWidget {
  const HijriDateWidget({super.key});

  @override
  State<HijriDateWidget> createState() => _HijriDateWidgetState();
}

class _HijriDateWidgetState extends State<HijriDateWidget> {
  HijriCalendar formattedDate =
      Get.put(HijriOffsetController()).getHijriDayByoffest();
  late Timer _timerMidnight;
  late Timer _timerMaghrib;
  late DateTime _nextMidnight;

  void _scheduleNextUpdate() {
    final hc = Get.put(HijriOffsetController());

    final now = DateTime.now();

    // NOTE: this handles updating the widget at maghrib.
    if (PrayerTimeings.getPrayersTimings() != null) {
      final maghrib = PrayerTimeings.getPrayersTimings()!.maghrib;
      // if now is after magrib then add one day. (new day starts after maghrib)
      if (now.isAfter(maghrib)) {
        formattedDate = hc.nextDayHijriDay();
        // HijriCalendar.fromDate(DateTime.now().add(const Duration(days: 1)));
      } else {
        // if now is before maghrib then date is the same.
        formattedDate = hc.getHijriDayByoffest();
        // HijriCalendar.now();
        // NOTE: and schedule the next update when it's open at maghrib.
        final duration = maghrib.difference(now);
        _timerMaghrib = Timer(duration, () {
          setState(() {
            _scheduleNextUpdate();
          });
        });
      }
    }

    // NOTE: this handles updating the widget when it's open at midnight.
    final todayAtMidnight = DateTime(now.year, now.month, now.day);
    final tomorrowAtMidnight = todayAtMidnight.add(const Duration(days: 1));

    if (now.isAfter(todayAtMidnight)) {
      _nextMidnight = tomorrowAtMidnight;
    } else {
      _nextMidnight = todayAtMidnight;
    }

    final durationUntilNextMidnight = _nextMidnight.difference(now);

    _timerMidnight = Timer(durationUntilNextMidnight, () {
      setState(() {
        formattedDate = HijriCalendar.now();
        _scheduleNextUpdate();
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _scheduleNextUpdate();
  }

  @override
  void dispose() {
    _timerMidnight.cancel();
    _timerMaghrib.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hc = Get.put(HijriOffsetController());
    return Obx(() {
      final date = hc.getHijriDayByoffest();
      return Text('${date.hDay} ${date.longMonthName} ${date.hYear}',
          style: Theme.of(context).textTheme.titleMedium);
    });
  }
}
