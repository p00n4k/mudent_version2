import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateThai extends StatelessWidget {
  final String startDateThai;
  final String endDateThai;

  const DateThai(
      {Key? key, required this.startDateThai, required this.endDateThai})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final startDateThaiTime = DateTime.parse(startDateThai);
    final endDateThaiTime = DateTime.parse(endDateThai);

    //plus 1 day before calculate
    final startDateThaiTimePlusOneDay =
        startDateThaiTime.add(Duration(days: 1));
    final endDateThaiTimePlusOneDay = endDateThaiTime.add(Duration(days: 1));

    final thaiDateThaiFormat = DateFormat('dd MMM yyyy', 'th');

    // check if start date and end date is not the same month
    if (startDateThaiTimePlusOneDay.month != endDateThaiTimePlusOneDay.month ||
        startDateThaiTimePlusOneDay.year != endDateThaiTimePlusOneDay.year) {
      return Text(
        '${startDateThaiTimePlusOneDay.day} ${thaiDateThaiFormat.dateSymbols.STANDALONEMONTHS[startDateThaiTimePlusOneDay.month - 1]} ${startDateThaiTimePlusOneDay.year + 543} - ${endDateThaiTimePlusOneDay.day} ${thaiDateThaiFormat.dateSymbols.STANDALONEMONTHS[endDateThaiTimePlusOneDay.month - 1]} ${endDateThaiTimePlusOneDay.year + 543}',
        style: TextStyle(
          fontSize: 16,
        ),
      );
    } else if (startDateThaiTimePlusOneDay.day ==
        endDateThaiTimePlusOneDay.day) {
      return Text(
        '${endDateThaiTimePlusOneDay.day} ${thaiDateThaiFormat.dateSymbols.STANDALONEMONTHS[startDateThaiTimePlusOneDay.month - 1]} ${endDateThaiTimePlusOneDay.year + 543}',
        style: TextStyle(
          fontSize: 16,
        ),
      );
    } else {
      return Text(
        '${startDateThaiTimePlusOneDay.day} - ${endDateThaiTimePlusOneDay.day} ${thaiDateThaiFormat.dateSymbols.STANDALONEMONTHS[startDateThaiTime.month - 1]} ${endDateThaiTime.year + 543}',
        style: TextStyle(
          fontSize: 16,
        ),
      );
    }
  }
}
