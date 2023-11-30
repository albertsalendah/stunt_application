// ignore_for_file: use_build_context_synchronously
import 'dart:math' as math;
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:stunt_application/custom_widget/popUpConfirm.dart';
import 'package:stunt_application/custom_widget/popUpLoading.dart';
import 'package:stunt_application/custom_widget/popup_error.dart';
import 'package:stunt_application/models/daftar_vaksin.dart';
import 'package:stunt_application/utils/get_umur.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../Bloc/AllBloc/all_bloc.dart';
import '../../Bloc/AllBloc/all_state.dart';
import '../../navigation_bar.dart';
import '../../custom_widget/popup_success.dart';
import '../../models/data_anak_model.dart';
import '../../models/kota_model.dart';
import '../../models/user.dart';
import '../../utils/SessionManager.dart';
import '../../utils/vaksin_notification.dart';
import 'botom_sheet_date_picker.dart';
import 'botom_sheet_drop_down.dart';
import 'bottomSheetVaksin.dart';
import 'imunisasi_api.dart';

class Imunisasi extends StatefulWidget {
  const Imunisasi({super.key});

  @override
  State<Imunisasi> createState() => _ImunisasiState();
}

class _ImunisasiState extends State<Imunisasi> {
  ImunisasiAPI api = ImunisasiAPI();
  User user = User();
  String token = '';
  int umurBln = 0;
  DataAnakModel dataAnak = DataAnakModel();
  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  List<KotaModel> listKota = [];
  List<String> kotaProvinsi = [];
  List<DaftarVaksinModel> daftarVaksin = [];
  TextEditingController umurController = TextEditingController();

  String lokasiVaksin = '';
  String tanggalVaksin = '';
  String tipeVaksin = '';

  final GlobalKey<State> vaksinLoadingkey = GlobalKey<State>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      user = await SessionManager.getUser();
      token = await SessionManager.getToken() ?? '';

      dataAnak = await SessionManager.getDataAnak();
      await fetchData(token);
      setState(() {});
    });
  }

  @override
  void dispose() {
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> fetchData(String token) async {
    await context.read<AllBloc>().getDataAnak(user: user, token: token);
    await context.read<AllBloc>().getDetailDataAnak(
        user: user, id_anak: dataAnak.id_anak ?? '', token: token);
    await context.read<AllBloc>().getListKota(token: token);
    await context.read<AllBloc>().getDaftarVaksin(umur: umurBln, token: token);
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                iconTheme: const IconThemeData(color: Colors.grey),
                title: Text(
                  'Jadwal Vaksin',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16 * fem,
                      color: Colors.black),
                ),
                leading: backbutton(fem, context)),
            backgroundColor: Colors.white,
            body: BlocBuilder<AllBloc, AllState>(
              builder: (context, state) {
                if (state is DataInitialState) {
                  return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              height: 40 * fem,
                              width: 40 * fem,
                              child: const CircularProgressIndicator()),
                          const SizedBox(
                            height: 8,
                          ),
                          const Text('Memuat Data')
                        ]),
                  );
                } else if (state is DataErrorState) {
                  return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error,
                            color: Colors.red,
                            size: 32 * fem,
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(state.errorMessage)
                        ]),
                  );
                } else if (state is DetailAnakLoaded) {
                  dataAnak = state.detailAnak;
                  umurBln = GetUmur().cekUmurBln(dataAnak.tanggallahir ?? '');
                  umurController.text =
                      GetUmur().umur(tglLahir: dataAnak.tanggallahir ?? '');
                } else if (state is ListKotaLoaded) {
                  listKota = state.listKota;
                  for (var item in listKota) {
                    kotaProvinsi.add('${item.name}, ${item.provincename}');
                  }
                } else if (state is DaftarVaksinLoaded) {
                  daftarVaksin = state.daftar_vaksin;
                  if (daftarVaksin.isNotEmpty) {
                    var copyList = List.from(daftarVaksin);
                    for (var item in copyList) {
                      if (item.namavaksin!.contains('HPV') &&
                          dataAnak.jeniskelamin != 'Perempuan') {
                        daftarVaksin.remove(item);
                      }
                    }
                  }
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await fetchData(token);
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          //reverse: true,
                          padding: EdgeInsets.only(
                              bottom:
                                  MediaQuery.of(context).viewInsets.bottom / 2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(
                                height: 1,
                                thickness: 1,
                                color: Colors.grey,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              const Text(
                                'Atur Jadwal Vasin',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              const Text(
                                'untuk mengatur jadwal vaksin,silahkan input data dibawah ini',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Umur'),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  TextFormField(
                                    readOnly: true,
                                    controller: umurController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              BotomSheetDropDown(
                                context: context,
                                focusNode: focusNodes[1],
                                useSearch: true,
                                label: 'Lokasi Vaksin',
                                modalLabel: 'Lokasi Vaksin',
                                list: kotaProvinsi,
                                onSelected: (value) {
                                  setState(() {
                                    lokasiVaksin = value;
                                  });
                                },
                                inputDecoration1: InputDecoration(
                                  suffixIcon: const Icon(
                                    Icons.location_city_outlined,
                                    color: Colors.grey,
                                  ),
                                  hintText: 'Lokasi Vaksin',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                reLoad: () async {
                                  await context
                                      .read<AllBloc>()
                                      .getListKota(token: token);
                                },
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              BotomSheetDatePicker(
                                context: context,
                                focusNode: focusNodes[2],
                                label: 'Tanggal Vaksin',
                                modalTitle: 'Tanggal Vaksin',
                                list: const [],
                                onSelected: (value) {
                                  setState(() {
                                    tanggalVaksin = value;
                                    log(tanggalVaksin);
                                  });
                                },
                                inputDecoration1: InputDecoration(
                                  suffixIcon: const Icon(
                                    Icons.calendar_month,
                                    color: Colors.grey,
                                  ),
                                  hintText: 'Tanggal Vaksin',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              BotomSheetVaksin(
                                context: context,
                                focusNode: focusNodes[3],
                                useSearch: false,
                                label: 'Tipe Vaksin',
                                modalLabel: 'Tipe Vaksin',
                                daftarVaksin: daftarVaksin,
                                onSelected: (value) {
                                  setState(() {
                                    tipeVaksin = value;
                                  });
                                },
                                inputDecoration1: InputDecoration(
                                  suffixIcon: const Icon(
                                    Icons.vaccines,
                                    color: Colors.grey,
                                  ),
                                  hintText: 'Tipe Vaksin',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                reLoad: () async {
                                  await context.read<AllBloc>().getDaftarVaksin(
                                      umur: umurBln, token: token);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                        height: 60,
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              backgroundColor: const Color(0xff3f7af6)),
                          onPressed: () async {
                            if (lokasiVaksin.isNotEmpty &&
                                tanggalVaksin.isNotEmpty &&
                                tipeVaksin.isNotEmpty) {
                              showDialog(
                                context: context,
                                builder: (contextConfirm) => PopUpConfirm(
                                  btnConfirmText: 'Simpan',
                                  btnCancelText: 'Batal',
                                  title: 'Simpan Jadwal Vaksin',
                                  message:
                                      'Simpan Jadwal Vaksin Ini? \n $tipeVaksin \n $tanggalVaksin',
                                  onPressed: () async {
                                    Navigator.pop(contextConfirm);
                                    showDialog(
                                      context: context,
                                      builder: (loadcontext) => PopUpLoading(
                                        key: vaksinLoadingkey,
                                      ),
                                    );
                                    try {
                                      await api
                                          .tambahJadwalVaksin(
                                              id_anak: dataAnak.id_anak ?? '',
                                              userID: user.userID ?? '',
                                              lokasi: lokasiVaksin,
                                              tanggal_vaksin: tanggalVaksin,
                                              tipe_vaksin: tipeVaksin,
                                              token: token)
                                          .then((result) {
                                        if (result.status) {
                                          Navigator.of(vaksinLoadingkey
                                                      .currentContext ??
                                                  context)
                                              .pop();
                                          try {
                                            VaksinNotification()
                                                .scheduleVaksinNotif(
                                                    notifID: math.Random()
                                                        .nextInt(9000),
                                                    tanggal: tanggalVaksin,
                                                    title:
                                                        'Imunisasi $tipeVaksin',
                                                    body:
                                                        'Imunisasi $tipeVaksin - $tanggalVaksin untuk ${dataAnak.namaanak}')
                                                .then((_) {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    PopUpSuccess(
                                                        message:
                                                            result.message ??
                                                                ''),
                                              );
                                            });
                                          } catch (errAlarm) {
                                            log('Error Saat Menambah Pengingat Vaksin => $errAlarm');
                                          }
                                        } else {
                                          showDialog(
                                            context: context,
                                            builder: (context) => PopUpError(
                                                message: result.message ?? ''),
                                          );
                                        }
                                      });
                                    } catch (error) {
                                      log('Error Tambah Jadwal Vaksin : $error');
                                      Navigator.of(
                                              vaksinLoadingkey.currentContext ??
                                                  context)
                                          .pop();
                                      showDialog(
                                        context: context,
                                        builder: (context) => const PopUpError(
                                            message:
                                                'Terjadi Kesalahan Saat Menyimpan Data'),
                                      );
                                    }
                                  },
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) => const PopUpError(
                                    message: 'Isi Semua Kolom'),
                              );
                            }
                          },
                          child: Center(
                            child: Text(
                              'Simpan & Ingatkan',
                              style: TextStyle(
                                  fontSize: 16 * ffem, color: Colors.white),
                            ),
                          ),
                        )),
                  ]),
                );
              },
            )),
      ),
    );
  }

  Column inputField(
      {required BuildContext context,
      required FocusNode focusNode,
      required bool useSearch,
      required String label,
      required List<String> list,
      required Function(String) onSelected,
      InputDecoration? inputDecoration1}) {
    TextEditingController localTextController = TextEditingController();
    TextEditingController searchController = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(
          height: 8,
        ),
        TextFormField(
            focusNode: focusNode,
            readOnly: true,
            controller: localTextController,
            decoration: inputDecoration1,
            onTap: () {
              focusNode.unfocus();
              showBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: Colors.white,
                elevation: 3,
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height / 2),
                builder: (context) => Column(
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
                                  const Expanded(
                                      child: Text(
                                    'Banyaknya',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  )),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: IconButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          icon: const Icon(Icons.close)),
                                    ),
                                  )
                                ],
                              )),
                          Visibility(
                              visible: useSearch,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                                child: TextFormField(
                                  controller: searchController,
                                  decoration: InputDecoration(
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
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight:
                              MediaQuery.of(context).size.height / 2 - 135),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                side: const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              title: Text(list[index]),
                              onTap: () {
                                localTextController.text = list[index];
                                onSelected(list[index]);
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
      ],
    );
  }

  Column datePicker({
    required BuildContext context,
    required FocusNode focusNode,
    required String label,
    required List<String> list,
    required Function(String) onSelected,
    InputDecoration? inputDecoration1,
  }) {
    TextEditingController localTextController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(
          height: 8,
        ),
        TextFormField(
            readOnly: true,
            focusNode: focusNode,
            controller: localTextController,
            decoration: inputDecoration1,
            onTap: () {
              focusNode.unfocus();
              showBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: Colors.white,
                elevation: 3,
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height / 1.3),
                builder: (context) => Column(
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
                                  const Expanded(
                                      child: Text(
                                    'Tanggal Vaksin',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  )),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: IconButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          icon: const Icon(Icons.close)),
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
                    TableCalendar(
                      firstDay: DateTime(2000),
                      lastDay: DateTime(2050),
                      focusedDay: DateTime.now(),
                      calendarFormat: CalendarFormat.month,
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
                            DateFormat('dd MMMM yyyy').format(date).toString();
                        onSelected(DateFormat('yyyy-MM-dd').format(date));
                        Navigator.pop(context);
                      },
                      calendarBuilders: CalendarBuilders(
                        selectedBuilder: (context, date, _) => Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              date.day.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
      ],
    );
  }

  Padding backbutton(double fem, BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0 * fem),
      child: Container(
        height: 20 * fem,
        width: 20 * fem,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xffe2e2e2)),
          color: const Color(0xffffffff),
          borderRadius: BorderRadius.circular(8 * fem),
        ),
        child: IconButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const Navigationbar(
                          index: 0,
                        )),
              );
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.grey,
              size: 16 * fem,
            )),
      ),
    );
  }
}
