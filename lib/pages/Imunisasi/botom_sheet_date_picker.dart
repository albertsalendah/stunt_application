
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class BotomSheetDatePicker extends StatefulWidget {
  final BuildContext context;
  final FocusNode focusNode;
  final String label;
  final String? modalTitle;
  final List<String> list;
  final Function(String) onSelected;
  final InputDecoration? inputDecoration1;
  const BotomSheetDatePicker({
    super.key,
    required this.context,
    required this.focusNode,
    required this.label,
    this.modalTitle,
    required this.list,
    required this.onSelected,
    this.inputDecoration1,
  });

  @override
  State<BotomSheetDatePicker> createState() => _BotomSheetDatePickerState();
}

class _BotomSheetDatePickerState extends State<BotomSheetDatePicker> {
  TextEditingController localTextController = TextEditingController();
  TextEditingController textTimeController = TextEditingController();
  DateTime selectedTgl = DateTime.now();
  FocusNode timeFocus = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      textTimeController.text = '08:00';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label),
        const SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: TextFormField(
                    readOnly: true,
                    focusNode: widget.focusNode,
                    controller: localTextController,
                    decoration: widget.inputDecoration1,
                    onTap: () {
                      widget.focusNode.unfocus();
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: Colors.white,
                        useSafeArea: true,
                        isDismissible: true,
                        elevation: 3,
                        isScrollControlled: true,
                        builder: (context) => Padding(
                          padding: MediaQuery.of(context).viewInsets,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                                child: Visibility(
                                              visible: widget.modalTitle !=
                                                      null &&
                                                  widget.modalTitle!.isNotEmpty,
                                              child: Text(
                                                widget.modalTitle ?? '',
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )),
                                            Expanded(
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: IconButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    icon: const Icon(
                                                        Icons.close)),
                                              ),
                                            )
                                          ],
                                        )),
                                  ],
                                ),
                              ),
                              const Divider(
                                height: 1,
                                thickness: 1,
                                color: Colors.grey,
                              ),
                              Container(
                                color: Colors.white,
                                child: TableCalendar(
                                  firstDay: DateTime(2000),
                                  lastDay: DateTime(2050),
                                  focusedDay: DateTime.now(),
                                  calendarFormat: CalendarFormat.month,
                                  availableCalendarFormats: const {
                                    CalendarFormat.month: "Month"
                                  },
                                  headerStyle:
                                      const HeaderStyle(titleCentered: true),
                                  calendarStyle: CalendarStyle(
                                    selectedDecoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    todayDecoration: const BoxDecoration(
                                      color: Color(0xff3f7af6),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  onDaySelected: (date, focusedDay) {
                                    localTextController.text =
                                        DateFormat('dd MMMM yyyy')
                                            .format(date)
                                            .toString();
                                    selectedTgl = date;
                                    widget.onSelected(
                                        '${DateFormat('yyyy-MM-dd').format(selectedTgl)} ${textTimeController.text}');
                                    Navigator.pop(context);
                                  },
                                  calendarBuilders: CalendarBuilders(
                                    selectedBuilder: (context, date, _) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          date.day.toString(),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: TextFormField(
                  focusNode: timeFocus,
                  readOnly: true,
                  controller: textTimeController,
                  decoration: InputDecoration(
                    suffixIcon: const Icon(
                      Icons.av_timer_sharp,
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onTap: () {
                    timeFocus.unfocus();
                    showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      backgroundColor: Colors.white,
                      useSafeArea: true,
                      isDismissible: true,
                      builder: (BuildContext builder) {
                        return SizedBox(
                          height: 280,
                          child: Column(
                            children: [
                              Container(
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 8, 8, 4),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Expanded(
                                            child: Text(
                                          'Pilih Jam Pengingat',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        )),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: IconButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              icon: const Icon(Icons.close)),
                                        )
                                      ],
                                    )),
                              ),
                              Container(
                                height: 230,
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: CupertinoDatePicker(
                                        mode: CupertinoDatePickerMode.time,
                                        use24hFormat: true,
                                        initialDateTime: DateTime.now(),
                                        onDateTimeChanged:
                                            (DateTime newDateTime) {
                                          setState(() {
                                            String formattedTime = DateFormat.Hm()
                                                .format(newDateTime);
                                            textTimeController.text =
                                                formattedTime;
                                            widget.onSelected(
                                                '${DateFormat('yyyy-MM-dd').format(selectedTgl)} ${textTimeController.text}');
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  String _formatTime(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
