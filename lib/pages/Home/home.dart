// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:stunt_application/custom_widget/blue_header_02.dart';
import 'package:stunt_application/custom_widget/jadwal_vaksin_card.dart';
import 'package:stunt_application/pages/Data_Pertumbuhan/data_pertumbuhan.dart';
import 'package:stunt_application/pages/Login_Register/logout.dart';
import 'package:stunt_application/pages/Menajemen_Gizi/menajemen_gizi.dart';
import 'package:stunt_application/utils/get_umur.dart';
import '../../Bloc/AllBloc/all_bloc.dart';
import '../../Bloc/AllBloc/all_state.dart';
import '../../models/data_anak_model.dart';
import '../../models/data_imt_5_18.dart';
import '../../models/data_tabel_status_gizi_model.dart';
import '../../models/jadwal_vaksin_model.dart';
import '../../models/user.dart';
import '../../utils/SessionManager.dart';
import '../../utils/hitung_gizi.dart';
import '../Data_Anak/data_anak.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User user = User();
  String token = '';
  DataAnakModel dataAnak = DataAnakModel();
  int umurBln = 0;
  List<int> umurTahun = [];
  List<DataTabelStatusGizi> list_imt_umur = [];
  List<DataIMT> list_imt_umur_518 = [];
  List<JadwalVaksinModel> listJadwalVaksin = [];
  List<DataAnakModel> listAnak = [];
  List<DropdownMenuEntry<DataAnakModel>> listofitems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      user = await fetch_user();
      token = await SessionManager.getToken() ?? '';
     // await fetch_data();
      if (listAnak.isEmpty) {
        await fetch_data();
      }
      umurBln = GetUmur().cekUmurBln(dataAnak.tanggallahir ?? '');
      umurTahun = GetUmur().Imtumur(tglLahir: dataAnak.tanggallahir ?? '');
      setState(() {});
    });
  }

  Future<User> fetch_user() async {
    return await SessionManager.getUser();
  }

  Future<void> fetch_data() async {
    await context.read<AllBloc>().getDataAnak(user: user, token: token);
    await context.read<AllBloc>().getDataTabelStatusGizi(
        jenisKelamin: dataAnak.jeniskelamin ?? '', token: token);
    dataAnak = await SessionManager.getDataAnak();
    if (dataAnak.id_anak != null) {
      await context.read<AllBloc>().getDetailDataAnak(
          user: user, id_anak: dataAnak.id_anak ?? '', token: token);
      await context.read<AllBloc>().getListJadwalVaksin(
          userID: user.userID ?? '',
          id_anak: dataAnak.id_anak ?? '',
          token: token);
    } else {
      if (listAnak.isNotEmpty) {
        await SessionManager.saveDataAnak(listAnak[0]);
        dataAnak = await SessionManager.getDataAnak();
        if (dataAnak.id_anak != null) {
          await context.read<AllBloc>().getDetailDataAnak(
              user: user, id_anak: dataAnak.id_anak ?? '', token: token);
          await context.read<AllBloc>().getListJadwalVaksin(
              userID: user.userID ?? '',
              id_anak: dataAnak.id_anak ?? '',
              token: token);
        }
      } else {
        await context.read<AllBloc>().getDataAnak(user: user, token: token);
      }
    }
    // String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    // await context.read<AllBloc>().getMenuMakan(
    //     userID: user.userID ?? '',
    //     id_anak: dataAnak.id_anak ?? '',
    //     tanggal: selectedDate,
    //     token: token);
    // await context.read<AllBloc>().getRekomendasiMenu(token: token);
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double fem = MediaQuery.of(context).size.width / baseWidth;
    double ffem = fem * 0.97;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SafeArea(
        child: Scaffold(
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
              } else if (state is DataAnakLoaded) {
                listAnak = state.dataAnak;
                listofitems.clear();
                for (var item in listAnak) {
                  listofitems.add(
                    DropdownMenuEntry(
                      value: item,
                      label: item.namaanak.toString(),
                    ),
                  );
                }
              } else if (state is DetailAnakLoaded) {
                dataAnak = state.detailAnak;
              } else if (state is DataTabelStatusGiziLoaded) {
                list_imt_umur = state.list_imt_umur;
                list_imt_umur_518 = state.list_imt_umur_518;
              } else if (state is ListJadwalVaksinLoaded) {
                listJadwalVaksin = state.listJadwalVaksin;
              }
              return RefreshIndicator(
                onRefresh: () async {
                  await fetch_data();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.flutter_dash,
                                color: Colors.grey,
                              )),
                          dropdownNamaAnak(context, listAnak, listofitems),
                          settingbutton(fem, context)
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      const Blue_Header_02(
                          text1: 'Amati pertumbuhan si kecil',
                          text2: 'Konsultasikan ke pakar gizi'),
                      data_anak(fem, ffem),
                      data_pertumbuhan(fem, ffem),
                      jadwal_imunisasi(fem, ffem)
                    ]),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Expanded dropdownNamaAnak(BuildContext context, List<DataAnakModel> list,
      List<DropdownMenuEntry<DataAnakModel>> listofitems) {
    return Expanded(
      child: listAnak.isNotEmpty
          ? DropdownMenu<DataAnakModel>(
              width: MediaQuery.of(context).size.width - 117,
              inputDecorationTheme: const InputDecorationTheme(
                  contentPadding: EdgeInsets.only(left: 8),
                  isDense: true,
                  border: InputBorder.none),
              onSelected: (DataAnakModel? value) async {
                if (value != null) {
                  dataAnak = value;
                  await SessionManager.saveDataAnak(value);
                  await fetch_data();
                }
              },
              initialSelection: dataAnak.id_anak != null && list.isNotEmpty
                  ? list.firstWhere(
                      (element) => element.id_anak == dataAnak.id_anak)
                  : list.first,
              dropdownMenuEntries: listofitems,
            )
          : const SizedBox(),
    );
  }

  GestureDetector data_anak(double fem, double ffem) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DataAnak(afterRegister: false),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 13 * fem),
        padding: EdgeInsets.fromLTRB(12 * fem, 10 * fem, 12 * fem, 10 * fem),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xfff0f0f0)),
          color: Colors.white, //Color(0xffffffff),
          borderRadius: BorderRadius.circular(12 * fem),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0f1b253e),
              offset: Offset(0 * fem, 2 * fem),
              blurRadius: 3.5 * fem,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 8 * fem),
              padding: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 2 * fem, 0 * fem),
              width: double.infinity,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(
                        0 * fem, 0 * fem, 239 * fem, 0 * fem),
                    child: Text(
                      'Data anak',
                      style: TextStyle(
                        fontSize: 10 * ffem,
                        fontWeight: FontWeight.w400,
                        height: 1.8 * ffem / fem,
                        color: const Color(0xff707070),
                      ),
                    ),
                  ),
                  InkWell(
                    child: SizedBox(
                        width: 12 * fem,
                        height: 12 * fem,
                        child: SvgPicture.asset(
                          "assets/images/arrow-up-right-from-square-solid.svg",
                          colorFilter: const ColorFilter.mode(
                              Colors.grey, BlendMode.srcIn),
                          height: 12 * fem,
                          width: 12 * fem,
                        )),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 8 * fem, 0 * fem),
              width: double.infinity,
              height: 57 * fem,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(
                        0 * fem, 0 * fem, 12 * fem, 0 * fem),
                    width: 56 * fem,
                    height: 56 * fem,
                    child: Image.asset(
                      "assets/images/group-115.png",
                      width: 56 * fem,
                      height: 56 * fem,
                    ),
                  ),
                  Expanded(
                    child: Visibility(
                      visible: (dataAnak.id_anak != null),
                      replacement: const Center(
                          child: Text('Belum Ada Data Anak Silahkan Diisi')),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.fromLTRB(
                                0 * fem, 0 * fem, 0 * fem, 3 * fem),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  dataAnak.namaanak ?? '',
                                  style: TextStyle(
                                    fontSize: 14 * ffem,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2125 * ffem / fem,
                                    color: const Color(0xff161f35),
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: (dataAnak.id_anak != null &&
                                          list_imt_umur.isNotEmpty &&
                                          list_imt_umur_518.isNotEmpty)
                                      ? [
                                          Container(
                                            margin: EdgeInsets.fromLTRB(0 * fem,
                                                0 * fem, 5 * fem, 3 * fem),
                                            width: 8 * fem,
                                            height: 8 * fem,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      4 * fem),
                                              color: HitungGizi()
                                                  .getStatusGizi(
                                                      context: context,
                                                      dataAnak: dataAnak,
                                                      umurBln: umurBln,
                                                      list_imt_umur_518:
                                                          list_imt_umur_518,
                                                      list_imt_umur:
                                                          list_imt_umur,
                                                      umurTahun: umurTahun)
                                                  .color,
                                            ),
                                          ),
                                          FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Text(
                                              HitungGizi()
                                                      .getStatusGizi(
                                                          context: context,
                                                          dataAnak: dataAnak,
                                                          umurBln: umurBln,
                                                          list_imt_umur_518:
                                                              list_imt_umur_518,
                                                          list_imt_umur:
                                                              list_imt_umur,
                                                          umurTahun: umurTahun)
                                                      .status ??
                                                  '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                height: 1.2125 * ffem / fem,
                                                color: const Color(0xff161f35),
                                              ),
                                            ),
                                          ),
                                        ]
                                      : [],
                                ),
                              ],
                            ),
                          ),
                          Text(
                            GetUmur()
                                .umur(tglLahir: dataAnak.tanggallahir ?? ''),
                            style: TextStyle(
                              fontSize: 14 * ffem,
                              fontWeight: FontWeight.w400,
                              height: 1.2125 * ffem / fem,
                              color: const Color(0xff2d2d2d),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container data_pertumbuhan(double fem, double ffem) {
    return Container(
      margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 29 * fem),
      width: double.infinity,
      height: 58.54 * fem,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            child: Container(
              margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 11 * fem, 0 * fem),
              padding: EdgeInsets.fromLTRB(
                  12 * fem, 12 * fem, 21.46 * fem, 12 * fem),
              height: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xfff0f0f0)),
                color: const Color(0xffffffff),
                borderRadius: BorderRadius.circular(10 * fem),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x0f1b253e),
                    offset: Offset(0 * fem, 2 * fem),
                    blurRadius: 3.5 * fem,
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(
                        0 * fem, 0 * fem, 11 * fem, 0 * fem),
                    width: 34.54 * fem,
                    height: 34.54 * fem,
                    child: Image.asset(
                      'assets/images/group-1-XrR.png',
                      width: 34.54 * fem,
                      height: 34.54 * fem,
                    ),
                  ),
                  Container(
                    margin:
                        EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 0 * fem),
                    constraints: BoxConstraints(
                      maxWidth: 78 * fem,
                    ),
                    child: Text(
                      'Data pertumbuhan',
                      style: TextStyle(
                        fontSize: 12 * ffem,
                        fontWeight: FontWeight.w500,
                        height: 1.4166666667 * ffem / fem,
                        color: const Color(0xff161f35),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const DataPertumbuhan()),
              );
            },
          ),
          InkWell(
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  12 * fem, 12 * fem, 32.46 * fem, 12 * fem),
              height: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xfff0f0f0)),
                color: const Color(0xffffffff),
                borderRadius: BorderRadius.circular(10 * fem),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x0f1b253e),
                    offset: Offset(0 * fem, 2 * fem),
                    blurRadius: 3.5 * fem,
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(
                        0 * fem, 0 * fem, 11 * fem, 0 * fem),
                    width: 34.54 * fem,
                    height: 34.54 * fem,
                    child: Image.asset(
                      'assets/images/group-1-G5P.png',
                      width: 34.54 * fem,
                      height: 34.54 * fem,
                    ),
                  ),
                  Container(
                    margin:
                        EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 0 * fem),
                    constraints: BoxConstraints(
                      maxWidth: 78 * fem,
                    ),
                    child: Text(
                      'Manajemen Gizi',
                      style: TextStyle(
                        fontSize: 12 * ffem,
                        fontWeight: FontWeight.w500,
                        height: 1.4166666667 * ffem / fem,
                        color: const Color(0xff161f35),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MenajemenGizi()),
              );
            },
          ),
        ],
      ),
    );
  }

  SizedBox jadwal_imunisasi(double fem, double ffem) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 12 * fem),
            child: Text(
              'Jadwal Immunisasi',
              style: TextStyle(
                fontSize: 12 * ffem,
                fontWeight: FontWeight.w500,
                height: 1.4166666667 * ffem / fem,
                color: const Color(0xff161f35),
              ),
            ),
          ),
          //Card
          SizedBox(
            height: 250,
            child: Visibility(
                visible: listJadwalVaksin.isNotEmpty,
                replacement:
                    const Center(child: Text('Belum Ada Jadwal Imunisasi')),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: listJadwalVaksin.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: JadwalVaksinCard(
                          fem: fem,
                          ffem: ffem,
                          tipeVaksin: listJadwalVaksin[index].tipevaksin ?? '',
                          tanggalVaksin:
                              listJadwalVaksin[index].tanggalvaksin ?? '',
                          lokasiVaksin: listJadwalVaksin[index].lokasi ?? ''),
                    );
                  },
                )),
          )
        ],
      ),
    );
  }

  Container settingbutton(double fem, BuildContext context) {
    return Container(
      height: 40 * fem,
      width: 40 * fem,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8 * fem),
        border: Border.all(color: const Color(0xffe2e2e2)),
        color: const Color(0xffffffff),
      ),
      margin: EdgeInsets.only(
        left: 4 * fem,
        right: 4 * fem,
        bottom: 4 * fem,
        top: 8 * fem,
      ),
      child: PopupMenuButton(
        icon: const Icon(
          Icons.settings,
          color: Colors.grey,
        ),
        itemBuilder: (context) {
          return <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(
                    Icons.logout,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text('Logout'),
                ],
              ),
            ),
          ];
        },
        onSelected: (value) {
          if (value == 'logout') {
            showDialog(
              context: context,
              builder: (context) {
                return const PopUpLogout();
              },
            );
          }
        },
      ),
    );
  }
}
