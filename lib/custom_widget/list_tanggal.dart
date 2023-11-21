import 'package:flutter/material.dart';

class ListTanggal extends StatefulWidget {
  final void Function(DateTime selectedDate) onDateSelected;
  const ListTanggal({Key? key, required this.onDateSelected}) : super(key: key);

  @override
  _ListTanggalState createState() => _ListTanggalState();
}

class _ListTanggalState extends State<ListTanggal> {
  late DateTime selectedDate;
  final currentDate = DateTime.now();
  final daysToShow = 7;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    selectedDate = currentDate;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentDate();
    });
  }

  void _scrollToCurrentDate() {
    const currentIndex = 2;
    final offset =
        currentIndex * (75.0 * MediaQuery.of(context).size.width / 375.0);
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Row(
        children: List.generate(daysToShow, (index) {
          final date = currentDate.subtract(Duration(
              days: 3 - index)); //currentDate.add(Duration(days: index));
          final isCurrentDate = date.day == currentDate.day;
          final isSelectedDate = date == selectedDate;

          return GestureDetector(
            onTap: () {
              selectedDate = date;
              widget.onDateSelected(selectedDate);
              setState(() {});
              // Call the callback to notify the selected date to the parent widget.
            },
            child: Container(
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.all(8.0),
              height: 85 * fem,
              width: 75 * fem,
              decoration: BoxDecoration(
                color: isSelectedDate
                    ? Colors.blue
                    : isCurrentDate
                        ? Colors.white
                        : const Color(0xfff0f0f0),
                border: Border.all(
                  color: isSelectedDate
                      ? Colors.blue
                      : isCurrentDate
                          ? Colors.blue
                          : const Color(0xfff0f0f0),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: isSelectedDate ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    _getDayOfWeek(date.weekday),
                    style: TextStyle(
                      fontSize: 16.0,
                      color: isSelectedDate
                          ? Colors.white
                          : const Color(0xff707070),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Senin';
      case DateTime.tuesday:
        return 'Selasa';
      case DateTime.wednesday:
        return 'Rabu';
      case DateTime.thursday:
        return 'Kamis';
      case DateTime.friday:
        return 'Jumat';
      case DateTime.saturday:
        return 'Sabtu';
      case DateTime.sunday:
        return 'Minggu';
      default:
        return '';
    }
  }
}
