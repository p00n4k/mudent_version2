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

    final thaiDateThaiFormat = DateFormat('dd MMM yyyy', 'th');

    final formattedStartDateThai = thaiDateThaiFormat
        .format(startDateThaiTime.add(Duration(days: 543 * 365)));
    final formattedEndDateThai = thaiDateThaiFormat
        .format(endDateThaiTime.add(Duration(days: 543 * 365)));

    // check if start date and end date is not the same month
    if (startDateThaiTime.month != endDateThaiTime.month ||
        startDateThaiTime.year != endDateThaiTime.year) {
      return Text(
        '$formattedStartDateThai - $formattedEndDateThai',
        style: TextStyle(
          fontSize: 16,
        ),
      );
    } else if (startDateThaiTime.day == endDateThaiTime.day) {
      return Text(
        '${endDateThaiTime.day} ${thaiDateThaiFormat.dateSymbols.STANDALONEMONTHS[startDateThaiTime.month - 1]} ${endDateThaiTime.year + 543}',
        style: TextStyle(
          fontSize: 16,
        ),
      );
    } else {
      return Text(
        '${startDateThaiTime.day} - ${endDateThaiTime.day} ${thaiDateThaiFormat.dateSymbols.STANDALONEMONTHS[startDateThaiTime.month - 1]} ${endDateThaiTime.year + 543}',
        style: TextStyle(
          fontSize: 16,
        ),
      );
    }
  }
}
