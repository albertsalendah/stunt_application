import 'package:flutter/material.dart';
import 'package:stunt_application/custom_widget/popup_status_gizi.dart';

import '../../models/daftar_vaksin.dart';

class BotomSheetVaksin extends StatefulWidget {
  final BuildContext context;
  final FocusNode focusNode;
  final bool useSearch;
  final String label;
  final String? modalLabel;
  final List<DaftarVaksinModel> daftarVaksin;
  final Function(String) onSelected;
  final InputDecoration? inputDecoration1;
  final Function() reLoad;
  const BotomSheetVaksin(
      {super.key,
      required this.context,
      required this.focusNode,
      required this.useSearch,
      required this.label,
      this.modalLabel,
      required this.daftarVaksin,
      required this.onSelected,
      this.inputDecoration1,
      required this.reLoad});

  @override
  State<BotomSheetVaksin> createState() => _BotomSheetVaksinState();
}

class _BotomSheetVaksinState extends State<BotomSheetVaksin> {
  List<String> list = [];
  TextEditingController localTextController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  List<String> searchfilteredList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (searchfilteredList.isEmpty) {
        searchfilteredList = list;
      }
      setState(() {});
    });
  }

  void updateSearchFilteredList() {
    final searchText = searchController.text.toLowerCase();
    setState(() {
      if (searchText.isEmpty) {
        searchfilteredList = list;
      } else {
        searchfilteredList = list
            .where((item) => item.toLowerCase().contains(searchText))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    list.clear();
    for (var item in widget.daftarVaksin) {
      list.add(item.namavaksin ?? '');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label),
        const SizedBox(
          height: 8,
        ),
        TextFormField(
            focusNode: widget.focusNode,
            readOnly: true,
            controller: localTextController,
            decoration: widget.inputDecoration1,
            onTap: () {
              widget.focusNode.unfocus();
              showModalBottomSheet(
                context: context,
                useSafeArea: true,
                isDismissible: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: Colors.white,
                elevation: 3,
                isScrollControlled: true,
                builder: (context) => Padding(
                  padding: MediaQuery.of(context).viewInsets / 2,
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
                                      visible: widget.modalLabel != null &&
                                          widget.modalLabel!.isNotEmpty,
                                      child: Text(
                                        widget.modalLabel ?? '',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )),
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                            onPressed: () {
                                              searchController.clear();
                                              Navigator.pop(context);
                                            },
                                            icon: const Icon(Icons.close)),
                                      ),
                                    )
                                  ],
                                )),
                            Visibility(
                                visible: widget.useSearch,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 0, 8, 4),
                                  child: TextFormField(
                                    controller: searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Cari Lokasi',
                                      suffixIcon: const Icon(
                                        Icons.search,
                                        color: Colors.grey,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                      if (searchfilteredList.isNotEmpty) ...[
                        ConstrainedBox(
                          constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height / 2 - 115),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: searchfilteredList.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                                child: ListTile(
                                  tileColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  trailing: IconButton(
                                    alignment: Alignment.centerRight,
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => PopUpStatusGizi(
                                            title: searchfilteredList[index],
                                            message: widget.daftarVaksin
                                                    .firstWhere(
                                                      (element) =>
                                                          element.namavaksin ==
                                                          searchfilteredList[
                                                              index],
                                                      orElse: () =>
                                                          DaftarVaksinModel(),
                                                    )
                                                    .keterangan ??
                                                ''),
                                      );
                                    },
                                    icon: const Icon(Icons.info),
                                  ),
                                  title: Text(searchfilteredList[index]),
                                  onTap: () {
                                    localTextController.text =
                                        searchfilteredList[index];
                                    widget
                                        .onSelected(searchfilteredList[index]);
                                    list.clear();
                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ] else ...[
                        SizedBox(
                          height: 100,
                          width: 100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    widget.reLoad();
                                    setState(() {});
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(Icons.refresh)),
                              const Text('Refresh...')
                            ],
                          ),
                        )
                      ]
                    ],
                  ),
                ),
              ).then((value) {
                searchController.clear();
              });
            }),
      ],
    );
  }
}
