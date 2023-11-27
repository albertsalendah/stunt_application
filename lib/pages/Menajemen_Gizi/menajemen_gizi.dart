// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:stunt_application/custom_widget/list_tanggal.dart';
import 'package:stunt_application/custom_widget/popUpConfirm.dart';
import 'package:stunt_application/custom_widget/popup_error.dart';
import 'package:stunt_application/custom_widget/popup_success.dart';

import '../../Bloc/AllBloc/all_bloc.dart';
import '../../Bloc/AllBloc/all_state.dart';
import '../../navigation_bar.dart';
import '../../models/api_massage.dart';
import '../../models/data_anak_model.dart';
import '../../models/menu_makan_model.dart';
import '../../models/rekomendasiMenu.dart';
import '../../models/user.dart';
import '../../utils/SessionManager.dart';
import 'menajemenGiziField.dart';
import 'menajemin_gizi_api.dart';

class MenajemenGizi extends StatefulWidget {
  const MenajemenGizi({super.key});

  @override
  State<MenajemenGizi> createState() => _MenajemenGiziState();
}

class _MenajemenGiziState extends State<MenajemenGizi> {
  late AllBloc allbloc;
  String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  MenajemenGiziApi api = MenajemenGiziApi();
  User user = User();
  String token = '';
  DataAnakModel dataAnak = DataAnakModel();
  List<MenuMakanModel> listMenuMakan = [];
  MenuMakanModel menuMakan = MenuMakanModel();
  List<RekomendasiMenu> listRekomendasi = [];
  RekomendasiMenu rekomendasiMenu = RekomendasiMenu();

  TextEditingController makananPokok = TextEditingController();
  TextEditingController makananPokokCount = TextEditingController();
  TextEditingController makananPokokMeasure = TextEditingController();

  TextEditingController sayur = TextEditingController();
  TextEditingController sayurCount = TextEditingController();
  TextEditingController sayurMeasure = TextEditingController();

  TextEditingController laukHewani = TextEditingController();
  TextEditingController laukHewaniCount = TextEditingController();
  TextEditingController laukHewaniMeasure = TextEditingController();

  TextEditingController laukNabati = TextEditingController();
  TextEditingController laukNabatiCount = TextEditingController();
  TextEditingController laukNabatiMeasure = TextEditingController();

  TextEditingController buah = TextEditingController();
  TextEditingController buahCount = TextEditingController();
  TextEditingController buahMeasure = TextEditingController();

  TextEditingController minuman = TextEditingController();
  TextEditingController minumanCount = TextEditingController();
  TextEditingController minumanMeasure = TextEditingController();

  TextEditingController jamMakan = TextEditingController();

  int selectedMenuMakan = 1;
  List<String> menu = [
    'Menu Makan Pagi',
    'Menu Makan Siang',
    'Menu Makan Malam'
  ];
  List<String> listSatuanMakan = [
    'Sdm (satu sendok makan)',
    'Sdt (satu sendok teh)',
    'Butir',
    'Potong',
    'Sendok Sayur',
    'Centong',
    'Buah',
    'Piring',
    'Mangkok'
  ];
  List<String> listSatuanMinuman = ['Gelas', 'Cangkir'];

  FocusNode timeFocus = FocusNode();
  List<FocusNode> focusNodes = List.generate(8, (index) => FocusNode());
  List<GlobalKey<FormState>> keys =
      List.generate(8, (index) => GlobalKey<FormState>());

  @override
  void initState() {
    super.initState();
    allbloc = context.read<AllBloc>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      user = await fetch_user();
      token = await SessionManager.getToken() ?? '';
      dataAnak = await SessionManager.getDataAnak();
      await fetchData(user, token);
      jamMakan.text = DateFormat.Hm().format(DateTime.now());
      if (listMenuMakan.isEmpty || listRekomendasi.isEmpty) {
        await fetchMenuMakan(user: user, token: token, tanggal: selectedDate);
      }
      setMenuMakan();
    });
  }

  @override
  void dispose() {
    timeFocus.dispose();
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void autoScroll(GlobalKey key) {
    if (key.currentContext != null) {
      Scrollable.ensureVisible(key.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.decelerate);
    }
  }

  Future<User> fetch_user() async {
    return await SessionManager.getUser();
  }

  Future<void> fetchData(User user, String token) async {
    await allbloc.getDetailDataAnak(
        user: user, id_anak: dataAnak.id_anak ?? '', token: token);
  }

  Future<void> fetchMenuMakan(
      {required User user,
      required String token,
      required String tanggal}) async {
    await allbloc.getMenuMakan(
        userID: user.userID ?? '',
        id_anak: dataAnak.id_anak ?? '',
        tanggal: tanggal,
        token: token);
    await allbloc.getRekomendasiMenu(token: token);
  }

  void setMenuMakan() {
    if (menuMakan.idmenu != null) {
      jamMakan.text = menuMakan.jam_makan.toString();
      makananPokok.text = menuMakan.makanpokok.toString();
      makananPokokCount.text = menuMakan.jumlahmk.toString();
      makananPokokMeasure.text = menuMakan.satuanmk.toString();
      sayur.text = menuMakan.sayur.toString();
      sayurCount.text = menuMakan.jumlahsayur.toString();
      sayurMeasure.text = menuMakan.satuansayur.toString();
      laukHewani.text = menuMakan.laukhewani.toString();
      laukHewaniCount.text = menuMakan.jumlahlaukhewani.toString();
      laukHewaniMeasure.text = menuMakan.satuanlaukhewani.toString();
      laukNabati.text = menuMakan.lauknabati.toString();
      laukNabatiCount.text = menuMakan.jumlahlauknabati.toString();
      laukNabatiMeasure.text = menuMakan.satuanlauknabati.toString();
      buah.text = menuMakan.buah.toString();
      buahCount.text = menuMakan.jumlahbuah.toString();
      buahMeasure.text = menuMakan.satuanbuah.toString();
      minuman.text = menuMakan.minuman.toString();
      minumanCount.text = menuMakan.jumlahminuman.toString();
      minumanMeasure.text = menuMakan.satuanminuman.toString();
    }
  }

  void clearField() {
    jamMakan.text = DateFormat.Hm().format(DateTime.now());
    makananPokok.clear();
    makananPokokCount.clear();
    makananPokokMeasure.text = listSatuanMakan[5];
    sayur.clear();
    sayurCount.clear();
    sayurMeasure.text = listSatuanMakan[4];
    laukHewani.clear();
    laukHewaniCount.clear();
    laukHewaniMeasure.text = listSatuanMakan[3];
    laukNabati.clear();
    laukNabatiCount.clear();
    laukNabatiMeasure.text = listSatuanMakan[3];
    buah.clear();
    buahCount.clear();
    buahMeasure.text = listSatuanMakan[6];
    minuman.clear();
    minumanCount.clear();
    minumanMeasure.text = listSatuanMinuman[0];
  }

  addMenuMakan() {
    showDialog(
      context: context,
      builder: (context) => PopUpConfirm(
        btnConfirmText: 'Simpan',
        btnCancelText: 'Batal',
        title: 'Tambah Menu Makan',
        message: menu[selectedMenuMakan - 1],
        onPressed: () async {
          API_Message result = await api.addMenuMakan(
              id_anak: dataAnak.id_anak ?? '',
              userID: user.userID ?? '',
              menu_makan: selectedMenuMakan,
              tanggal: selectedDate,
              jam_makan: jamMakan.text,
              makan_pokok: makananPokok.text,
              jumlah_mk: makananPokokCount.text,
              satuan_mk: makananPokokMeasure.text,
              sayur: sayur.text,
              jumlah_sayur: sayurCount.text,
              satuan_sayur: sayurMeasure.text,
              lauk_hewani: laukHewani.text,
              jumlah_lauk_hewani: laukHewaniCount.text,
              satuan_lauk_hewani: laukHewaniMeasure.text,
              lauk_nabati: laukNabati.text,
              jumlah_lauk_nabati: laukNabatiCount.text,
              satuan_lauk_nabati: laukNabatiMeasure.text,
              buah: buah.text,
              jumlah_buah: buahCount.text,
              satuan_buah: buahMeasure.text,
              minuman: minuman.text,
              jumlah_minuman: minumanCount.text,
              satuan_minuman: minumanMeasure.text,
              token: token);
          if (result.status) {
            Navigator.pop(context);
            await fetchMenuMakan(
                user: user, token: token, tanggal: selectedDate);
            showDialog(
              context: context,
              builder: (context) => PopUpSuccess(message: result.message ?? ''),
            ).then((value) {
              setState(() {
                clearField();
                setMenuMakan();
              });
            });
          } else {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) => PopUpError(message: result.message ?? ''),
            );
          }
        },
      ),
    );
  }

  updateMenuMakan() {
    showDialog(
      context: context,
      builder: (context) => PopUpConfirm(
        btnConfirmText: 'Simpan',
        btnCancelText: 'Batal',
        title: 'Ubah Menu Manakn',
        message: 'Ubah ${menu[selectedMenuMakan - 1]}',
        onPressed: () async {
          API_Message result = await api.updateMenuMakan(
            id_menu: menuMakan.idmenu ?? '',
            jam_makan: jamMakan.text,
            makan_pokok: makananPokok.text,
            jumlah_mk: makananPokokCount.text,
            satuan_mk: makananPokokMeasure.text,
            sayur: sayur.text,
            jumlah_sayur: sayurCount.text,
            satuan_sayur: sayurMeasure.text,
            lauk_hewani: laukHewani.text,
            jumlah_lauk_hewani: laukHewaniCount.text,
            satuan_lauk_hewani: laukHewaniMeasure.text,
            lauk_nabati: laukNabati.text,
            jumlah_lauk_nabati: laukNabatiCount.text,
            satuan_lauk_nabati: laukNabatiMeasure.text,
            buah: buah.text,
            jumlah_buah: buahCount.text,
            satuan_buah: buahMeasure.text,
            minuman: minuman.text,
            jumlah_minuman: minumanCount.text,
            satuan_minuman: minumanMeasure.text,
            token: token,
          );
          if (result.status) {
            Navigator.pop(context);
            await fetchMenuMakan(
                user: user, token: token, tanggal: selectedDate);
            showDialog(
              context: context,
              builder: (context) => PopUpSuccess(message: result.message ?? ''),
            ).then((value) {
              menuMakan = listMenuMakan.firstWhere(
                (element) {
                  return formatTglMenu(element.tanggal.toString()) ==
                          selectedDate &&
                      element.menumakan == selectedMenuMakan;
                },
                orElse: () => MenuMakanModel(),
              );
              setState(() {
                clearField();
                setMenuMakan();
              });
            });
          } else {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder: (context) => PopUpError(message: result.message ?? ''),
            );
          }
        },
      ),
    );
  }

  //hapus .add(const Duration(days: 1)) saat deploy
  String formatTglMenu(String tgl) {
    DateTime parsedDate = DateTime.parse(tgl);
    return DateFormat('yyyy-MM-dd').format(parsedDate).toString();
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              iconTheme: const IconThemeData(color: Colors.grey),
              title: Text(
                'Menajemen Gizi',
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
              } else if (state is MenuMakanLoaded) {
                listMenuMakan = state.menuMakan;
                menuMakan = listMenuMakan.firstWhere(
                  (element) {
                    return formatTglMenu(element.tanggal.toString()) ==
                            selectedDate &&
                        element.menumakan == selectedMenuMakan;
                  },
                  orElse: () => MenuMakanModel(),
                );
              } else if (state is RekomendasiMenuLoaded) {
                listRekomendasi = state.rekomendasiMenu;
              }
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  ListTanggal(
                    onDateSelected: (date) {
                      setState(() {
                        selectedDate = DateFormat('yyyy-MM-dd').format(date);
                        menuMakan = listMenuMakan.firstWhere(
                          (element) {
                            return element.menumakan == selectedMenuMakan &&
                                selectedDate ==
                                    formatTglMenu(element.tanggal.toString());
                          },
                          orElse: () => MenuMakanModel(),
                        );
                        clearField();
                        setMenuMakan();
                      });
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom / 2),
                      reverse: false,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: DropdownMenu<String>(
                              width: MediaQuery.of(context).size.width - 17,
                              inputDecorationTheme: InputDecorationTheme(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10))),
                              onSelected: (String? value) {
                                if (value != null) {
                                  selectedMenuMakan = menu.indexOf(value) + 1;
                                }
                                menuMakan = listMenuMakan.firstWhere(
                                  (element) {
                                    return element.menumakan ==
                                            selectedMenuMakan &&
                                        selectedDate ==
                                            formatTglMenu(
                                                element.tanggal.toString());
                                  },
                                  orElse: () => MenuMakanModel(),
                                );
                                clearField();
                                setMenuMakan();
                                setState(() {});
                              },
                              initialSelection: menu.first,
                              dropdownMenuEntries: menu
                                  .map<DropdownMenuEntry<String>>(
                                      (String value) {
                                return DropdownMenuEntry<String>(
                                    value: value, label: value);
                              }).toList(),
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          listRekomendasiMenu(context),
                          const SizedBox(
                            height: 16,
                          ),
                          jamMakanPicker(),
                          const SizedBox(
                            height: 16,
                          ),
                          Focus(
                            key: keys[0],
                            focusNode: focusNodes[0],
                            onFocusChange: (hasFocus) {
                              if (hasFocus) {
                                autoScroll(keys[0]);
                              }
                            },
                            child: MenajemenGiziField(
                                label: 'Makanan Pokok',
                                hint: 'Nasi',
                                hintM: listSatuanMakan[5],
                                list: listSatuanMakan,
                                mainController: makananPokok,
                                countController: makananPokokCount,
                                measurementController: makananPokokMeasure,
                                onEditingComplete: () {
                                  focusNodes[1].requestFocus();
                                }),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Focus(
                            key: keys[1],
                            focusNode: focusNodes[1],
                            onFocusChange: (hasFocus) {
                              if (hasFocus) {
                                autoScroll(keys[1]);
                              }
                            },
                            child: MenajemenGiziField(
                                label: 'Sayur',
                                hint: 'Bayam',
                                hintM: listSatuanMakan[4],
                                list: listSatuanMakan,
                                mainController: sayur,
                                countController: sayurCount,
                                measurementController: sayurMeasure,
                                onEditingComplete: () {
                                  focusNodes[2].requestFocus();
                                }),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Focus(
                            key: keys[2],
                            focusNode: focusNodes[2],
                            onFocusChange: (hasFocus) {
                              if (hasFocus) {
                                autoScroll(keys[2]);
                              }
                            },
                            child: MenajemenGiziField(
                                label: 'Lauk Hewani',
                                hint: 'Ikan',
                                hintM: listSatuanMakan[3],
                                list: listSatuanMakan,
                                mainController: laukHewani,
                                countController: laukHewaniCount,
                                measurementController: laukHewaniMeasure,
                                onEditingComplete: () {
                                  focusNodes[3].requestFocus();
                                }),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Focus(
                            key: keys[3],
                            focusNode: focusNodes[3],
                            onFocusChange: (hasFocus) {
                              if (hasFocus) {
                                autoScroll(keys[3]);
                              }
                            },
                            child: MenajemenGiziField(
                                label: 'Lauk Nabati',
                                hint: 'Tahu',
                                hintM: listSatuanMakan[3],
                                list: listSatuanMakan,
                                mainController: laukNabati,
                                countController: laukNabatiCount,
                                measurementController: laukNabatiMeasure,
                                onEditingComplete: () {
                                  focusNodes[4].requestFocus();
                                }),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Focus(
                            key: keys[4],
                            focusNode: focusNodes[4],
                            onFocusChange: (hasFocus) {
                              autoScroll(keys[4]);
                            },
                            child: MenajemenGiziField(
                                label: 'Buah',
                                hint: 'Apel',
                                hintM: listSatuanMakan[6],
                                list: listSatuanMakan,
                                mainController: buah,
                                countController: buahCount,
                                measurementController: buahMeasure,
                                onEditingComplete: () {
                                  focusNodes[5].requestFocus();
                                }),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Focus(
                            key: keys[5],
                            focusNode: focusNodes[5],
                            onFocusChange: (hasFocus) {
                              autoScroll(keys[5]);
                            },
                            child: MenajemenGiziField(
                                label: 'Minuman',
                                hint: 'Susu',
                                hintM: listSatuanMinuman[0],
                                list: listSatuanMinuman,
                                mainController: minuman,
                                countController: minumanCount,
                                measurementController: minumanMeasure,
                                onEditingComplete: () {}),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom /
                                        3),
                          )
                        ],
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
                      onPressed: () {
                        if (menuMakan.idmenu == null) {
                          addMenuMakan();
                        } else {
                          updateMenuMakan();
                        }
                      },
                      child: Center(
                        child: Text(
                          menuMakan.idmenu == null ? 'Simpan' : 'Update',
                          style: TextStyle(
                              fontSize: 16 * ffem, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ]),
              );
            },
          ),
        ),
      ),
    );
  }

  GestureDetector listRekomendasiMenu(BuildContext context) {
    return GestureDetector(
      onTap: () {
        rekomendasiMenu = listRekomendasi.firstWhere(
          (element) => element.menumakan == selectedMenuMakan,
          orElse: () => RekomendasiMenu(),
        );
        showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: Colors.white,
          builder: (BuildContext context) {
            return SizedBox(
              height: 500,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Text(
                              menu[selectedMenuMakan - 1],
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
                    height: 268,
                    child: ListView(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      shrinkWrap: true,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 4),
                          child: ListTile(
                            tileColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            title:
                                Text(rekomendasiMenu.makananpokok.toString()),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 4),
                          child: ListTile(
                            tileColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            title: Text(rekomendasiMenu.sayur.toString()),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 4),
                          child: ListTile(
                            tileColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            title: Text(rekomendasiMenu.laukhewani.toString()),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 4),
                          child: ListTile(
                            tileColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            title: Text(rekomendasiMenu.lauknabati.toString()),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 4),
                          child: ListTile(
                            tileColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            title: Text(rekomendasiMenu.buah.toString()),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 4),
                          child: ListTile(
                            tileColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            title: Text(rekomendasiMenu.minuman.toString()),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8, right: 8, top: 5, bottom: 5),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              backgroundColor: const Color(0xff3f7af6)),
                          onPressed: () {
                            setState(() {
                              jamMakan.text =
                                  rekomendasiMenu.jammakan.toString();
                              makananPokok.text =
                                  rekomendasiMenu.makananpokok.toString();
                              makananPokokCount.text =
                                  rekomendasiMenu.jumlahmk.toString();
                              makananPokokMeasure.text =
                                  rekomendasiMenu.satuanmk.toString();
                              sayur.text = rekomendasiMenu.sayur.toString();
                              sayurCount.text =
                                  rekomendasiMenu.jumlahsayur.toString();
                              sayurMeasure.text =
                                  rekomendasiMenu.satuansayur.toString();
                              laukHewani.text =
                                  rekomendasiMenu.laukhewani.toString();
                              laukHewaniCount.text =
                                  rekomendasiMenu.jumlahlaukhewani.toString();
                              laukHewaniMeasure.text =
                                  rekomendasiMenu.satuanlaukhewani.toString();
                              laukNabati.text =
                                  rekomendasiMenu.lauknabati.toString();
                              laukNabatiCount.text =
                                  rekomendasiMenu.jumlahlauknabati.toString();
                              laukNabatiMeasure.text =
                                  rekomendasiMenu.satuanlauknabati.toString();
                              buah.text = rekomendasiMenu.buah.toString();
                              buahCount.text =
                                  rekomendasiMenu.jumlahbuah.toString();
                              buahMeasure.text =
                                  rekomendasiMenu.satuanbuah.toString();
                              minuman.text = rekomendasiMenu.minuman.toString();
                              minumanCount.text =
                                  rekomendasiMenu.jumlahminuman.toString();
                              minumanMeasure.text =
                                  rekomendasiMenu.satuanminuman.toString();
                            });
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Simpan',
                            style: TextStyle(color: Colors.white),
                          )),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
      child: Container(
        height: 55,
        decoration: BoxDecoration(
            color: Colors.blue.shade50,
            border: Border.all(color: const Color(0xff3f7af6)),
            borderRadius: BorderRadius.circular(10)),
        child: const Row(children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text('Rekomendasi Asupan'),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(
              Icons.info_outline,
              color: Color(0xff3f7af6),
            ),
          )
        ]),
      ),
    );
  }

  Column jamMakanPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Jam Makan',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(
          height: 8,
        ),
        TextFormField(
          focusNode: timeFocus,
          readOnly: true,
          controller: jamMakan,
          decoration: InputDecoration(
            suffixIcon: const Icon(
              Icons.av_timer_sharp,
              color: Colors.grey,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onTap: () async {
            timeFocus.unfocus();
            showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              backgroundColor: Colors.white,
              useSafeArea: true,
              isDismissible: true,
              //isScrollControlled: true,
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
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      SizedBox(
                        height: 230,
                        child: Column(
                          children: [
                            Expanded(
                              child: CupertinoDatePicker(
                                mode: CupertinoDatePickerMode.time,
                                use24hFormat: true,
                                initialDateTime: DateTime.now(),
                                onDateTimeChanged: (DateTime newDateTime) {
                                  setState(() {
                                    String formattedTime =
                                        DateFormat.Hm().format(newDateTime);
                                    jamMakan.text = formattedTime;
                                    focusNodes[0].requestFocus();
                                    autoScroll(keys[0]);
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
                ),
              ),
            );
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.grey,
            size: 16 * fem,
          ),
        ),
      ),
    );
  }
}
