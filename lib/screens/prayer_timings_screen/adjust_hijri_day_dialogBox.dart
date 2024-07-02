import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:yosria/services/shared_prefs.dart';

class AdjustHijriDayDialogbox extends StatefulWidget {
  const AdjustHijriDayDialogbox({super.key});

  @override
  State<AdjustHijriDayDialogbox> createState() =>
      _AdjustHijriDayDialogboxState();
}

class _AdjustHijriDayDialogboxState extends State<AdjustHijriDayDialogbox> {
  final hc = Get.put(HijriOffsetController());

  var offset = Get.put(HijriOffsetController()).offset.value;

  @override
  Widget build(BuildContext context) {
    final fontSize = Theme.of(context).textTheme.titleMedium!.fontSize;
    return AlertDialog(
      content: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: fontSize! * 2),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment<int>(
                value: -2,
                label: Text('-2'),
              ),
              ButtonSegment<int>(
                value: -1,
                label: Text('-1'),
              ),
              ButtonSegment<int>(
                value: 0,
                label: Text('0'),
              ),
              ButtonSegment<int>(
                value: 1,
                label: Text('1'),
              ),
              ButtonSegment<int>(
                value: 2,
                label: Text('2'),
              ),
            ],
            selected: <int>{offset},
            onSelectionChanged: (value) {
              // widget.onData(value.first.name);
              setState(
                () {
                  offset = value.first;
                },
              );
            },
          )),
      actions: [
        ElevatedButton(
          onPressed: () {
            hc.setHiJriDayOffset(offset);
            Navigator.pop(context);
          },
          child: const Text('تأكيد'),
        ),
      ],
    );
  }
}

class HijriOffsetController extends GetxController {
  var offset = SharedPreferencesService.getHijriDayOffset().obs;

  HijriCalendar getHijriDayByoffest() {
    final adjustedDate = DateTime.now().add(Duration(days: offset.value));
    return HijriCalendar.fromDate(adjustedDate);
  }

  HijriCalendar nextDayHijriDay() {
    final adjustedDate = DateTime.now().add(Duration(days: offset.value + 1));
    return HijriCalendar.fromDate(adjustedDate);
  }

  setHiJriDayOffset(int i) {
    offset.value = i;
    SharedPreferencesService.setHijriDayOffset(i);
  }

  Text formatDate(BuildContext context, HijriCalendar date) {
    late String arabicMonth;
    switch (date.hMonth) {
      case 1:
        arabicMonth = 'محرم';
      case 2:
        arabicMonth = 'صفر';
      case 3:
        arabicMonth = 'ربيع الأول';
      case 4:
        arabicMonth = 'ربيع الثاني';
      case 5:
        arabicMonth = 'جمادى الأولى';
      case 6:
        arabicMonth = 'جمادى الثانية';
      case 7:
        arabicMonth = 'رجب';
      case 8:
        arabicMonth = 'شعبان';
      case 9:
        arabicMonth = 'رمضان';
      case 10:
        arabicMonth = 'شوال';
      case 11:
        arabicMonth = 'ذوالقعدة';
      case 12:
        arabicMonth = 'ذوالحجة';
    }

    return Text('${getHijriDayByoffest().hDay} $arabicMonth ${date.hYear}',
        style: Theme.of(context).textTheme.titleMedium);
    // return Text('${hc.getHijriDayByoffest().hDay} $arabicMonth ${formattedDate.hYear}'),
  }
}
