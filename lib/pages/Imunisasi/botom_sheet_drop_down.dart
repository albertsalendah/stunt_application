import 'package:flutter/material.dart';

class BotomSheetDropDown extends StatefulWidget {
  final BuildContext context;
  final FocusNode focusNode;
  final bool useSearch;
  final String label;
  final String? modalLabel;
  final List<String> list;
  final Function(String) onSelected;
  final InputDecoration? inputDecoration1;
  final Function() reLoad;
  const BotomSheetDropDown(
      {super.key,
      required this.context,
      required this.focusNode,
      required this.useSearch,
      required this.label,
      this.modalLabel,
      required this.list,
      required this.onSelected,
      this.inputDecoration1,
      required this.reLoad});

  @override
  State<BotomSheetDropDown> createState() => _BotomSheetDropDownState();
}

class _BotomSheetDropDownState extends State<BotomSheetDropDown> {
  TextEditingController localTextController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {});
  }

  List<String> get searchfilteredList {
    return widget.list.where((item) {
      bool mNama = true;
      if (searchController.text.isNotEmpty) {
        mNama =
            item.toLowerCase().contains(searchController.text.toLowerCase());
      }
      return mNama;
    }).toList();
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
                                    onChanged: (value) {
                                      searchfilteredList.clear();
                                      setState(() {});
                                    },
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
                                child: ListTile(tileColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: const BorderSide(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  title: Text(searchfilteredList[index]),
                                  onTap: () {
                                    localTextController.text =
                                        searchfilteredList[index];
                                    widget
                                        .onSelected(searchfilteredList[index]);
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
                                    searchController.clear();
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
