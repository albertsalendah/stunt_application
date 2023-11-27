import 'package:flutter/material.dart';

class MenajemenGiziField extends StatefulWidget {
  final String label;
  final String hint;
  final String hintM;
  final List<String> list;
  final TextEditingController mainController;
  final TextEditingController countController;
  final TextEditingController measurementController;
  final VoidCallback onEditingComplete;
  const MenajemenGiziField(
      {super.key,
      required this.label,
      required this.hint,
      required this.hintM,
      required this.list,
      required this.mainController,
      required this.countController,
      required this.measurementController,
      required this.onEditingComplete});

  @override
  State<MenajemenGiziField> createState() => _MenajemenGiziFieldState();
}

class _MenajemenGiziFieldState extends State<MenajemenGiziField> {
  FocusNode main = FocusNode();
  FocusNode count = FocusNode();
  FocusNode measure = FocusNode();
  @override
  void initState() {
    super.initState();
    widget.measurementController.text = widget.hintM;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(
          height: 8,
        ),
        Container(
          height: 100,
          padding: const EdgeInsets.only(left: 8, right: 8),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10)),
          child: Column(children: [
            TextField(
              focusNode: main,
              controller: widget.mainController,
              onEditingComplete: () {
                count.requestFocus();
              },
              decoration: InputDecoration(
                  hintText: 'Contoh : ${widget.hint}',
                  border: const UnderlineInputBorder(
                      borderSide: BorderSide(width: 1))),
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    focusNode: count,
                    controller: widget.countController,
                    onEditingComplete: () {
                      measure.requestFocus();
                    },
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: false),
                    decoration: const InputDecoration(
                        hintText: "0", border: InputBorder.none),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Focus(
                    focusNode: measure,
                    onFocusChange: (hasFocus) {
                      if (hasFocus) {
                        showModal();
                      }
                    },
                    child: TextFormField(
                      controller: widget.measurementController,
                      readOnly: true,
                      textAlign: TextAlign.end,
                      onChanged: (value) {
                        widget.onEditingComplete;
                      },
                      decoration: InputDecoration(
                        hintText: widget.hintM,
                        border: InputBorder.none,
                        suffixIcon: const Icon(Icons.arrow_drop_down),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ]),
        ),
      ],
    );
  }

  showModal() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        measure.unfocus();
        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(
                        'Banyaknya ${widget.label}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
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
            SizedBox(
              height: 335,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.list.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      title: Text(widget.list[index]),
                      onTap: () {
                        widget.measurementController.text = widget.list[index];
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
