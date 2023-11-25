// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:stunt_application/custom_widget/popUpConfirm.dart';
import '../../Bloc/AllBloc/all_bloc.dart';
import '../../Bloc/AllBloc/all_state.dart';
import '../../navigation_bar.dart';
import '../../custom_widget/popup_error.dart';
import '../../custom_widget/popup_success.dart';
import '../../models/api_massage.dart';
import '../../models/data_anak_model.dart';
import '../../models/data_imt_5_18.dart';
import '../../models/data_tabel_status_gizi_model.dart';
import '../../models/user.dart';
import '../../utils/SessionManager.dart';
import '../../utils/get_umur.dart';
import '../../utils/hitung_gizi.dart';
import '../Data_Anak/data_anak_api.dart';

class DataPertumbuhan extends StatefulWidget {
  const DataPertumbuhan({super.key});

  @override
  State<DataPertumbuhan> createState() => _DataPertumbuhanState();
}

class _DataPertumbuhanState extends State<DataPertumbuhan> {
  DataAnakApi api = DataAnakApi();
  User user = User();
  String token = '';
  int umurBln = 0;
  List<int> umurTahun = [];
  DataAnakModel dataAnak = DataAnakModel();
  TextEditingController conUmur = TextEditingController();
  TextEditingController berat_badan = TextEditingController();
  TextEditingController tinggi_badan = TextEditingController();
  TextEditingController lingkar_kepala = TextEditingController();
  String selectedPengukuran = '';

  //LIST
  List<DataTabelStatusGizi> list_bb_umur = [];
  List<DataTabelStatusGizi> list_tb_umur = [];
  List<DataTabelStatusGizi> list_bb_pb = [];
  List<DataTabelStatusGizi> list_bb_tb = [];
  List<DataTabelStatusGizi> list_imt_umur = [];
  List<DataIMT> list_imt_umur_518 = [];
  List<String> ukur = ['Dikukur Terlentang', 'Dikukur Berdiri'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      selectedPengukuran = ukur.first;
      user = await fetch_user();
      token = await SessionManager.getToken() ?? '';
      dataAnak = await SessionManager.getDataAnak();
      await fetch_data();
      umurBln = GetUmur().cekUmurBln(dataAnak.tanggallahir ?? '');
      umurTahun = GetUmur().Imtumur(tglLahir: dataAnak.tanggallahir ?? '');
      setData();
    });
  }

  Future<User> fetch_user() async {
    return await SessionManager.getUser();
  }

  Future<void> fetch_data() async {
    await context.read<AllBloc>().getDetailDataAnak(
        user: user, id_anak: dataAnak.id_anak ?? '', token: token);
    await context.read<AllBloc>().getDataTabelStatusGizi(
        jenisKelamin: dataAnak.jeniskelamin ?? '', token: token);
  }

  void setData() {
    conUmur.text = GetUmur().umur(tglLahir: dataAnak.tanggallahir ?? '');
    berat_badan.text = dataAnak.beratbadan ?? '';
    tinggi_badan.text = dataAnak.tinggibadan ?? '';
    lingkar_kepala.text = dataAnak.lingkarkepala ?? '';
  }

  String setTgl(String? tgl) {
    if (tgl != null && tgl != '0000-00-00') {
      DateTime date = DateFormat('yyyy-MM-dd').parse(tgl);
      return DateFormat('dd MMMM yyyy')
          .format(date.add(const Duration(days: 1)));
    } else {
      return '';
    }
  }

  Future<void> updateDataAnak() async {
    //api.addDataAnak(userID: userID, token: token)

    if (user.userID != null &&
        '${user.userID}'.isNotEmpty &&
        token.isNotEmpty &&
        berat_badan.text.isNotEmpty &&
        tinggi_badan.text.isNotEmpty) {
      log('message');
      API_Message result = await api.updateDataAnak(
          id_anak: dataAnak.id_anak ?? '',
          userID: user.userID ?? '',
          namaAnak: dataAnak.namaanak ?? '',
          jenisKelamin: dataAnak.jeniskelamin ?? '',
          tanggalLahir: dataAnak.tanggallahir ?? '',
          beratbadan: berat_badan.text,
          tinggibadan: tinggi_badan.text,
          lingkarkepala: dataAnak.lingkarkepala ?? '',
          token: token);
      if (result.status) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => PopUpSuccess(message: result.message ?? ''),
        );
        fetch_data();
      } else {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => PopUpError(message: result.message ?? ''),
        );
        fetch_data();
      }
    }
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
                  'Data Pertumbuhan',
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
                } else if (state is DataTabelStatusGiziLoaded) {
                  list_bb_umur = state.list_bb_umur;
                  list_tb_umur = state.list_tb_umur;
                  list_bb_pb = state.list_bb_pb;
                  list_bb_tb = state.list_bb_tb;
                  list_imt_umur = state.list_imt_umur;
                  list_imt_umur_518 = state.list_imt_umur_518;
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: [
                    if (dataAnak.id_anak != null &&
                        list_imt_umur.isNotEmpty &&
                        list_imt_umur_518.isNotEmpty) ...[
                      data_anak(fem, ffem),
                    ],
                    const SizedBox(
                      height: 16,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            textfield(fem, 'Umur', conUmur),
                            const SizedBox(
                              height: 16,
                            ),
                            textfield(fem, 'Berat Badan', berat_badan),
                            const SizedBox(
                              height: 16,
                            ),
                            Visibility(
                              visible: GetUmur().cekUmurBln(
                                      dataAnak.tanggallahir ?? '') ==
                                  24,
                              child: DropdownMenu<String>(
                                width: MediaQuery.of(context).size.width - 16,
                                inputDecorationTheme: InputDecorationTheme(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                                onSelected: (String? value) {
                                  setState(() {
                                    if (value != null) {
                                      selectedPengukuran = value;
                                    }
                                  });
                                  FocusScope.of(context).nextFocus();
                                },
                                initialSelection: ukur.first,
                                dropdownMenuEntries: ukur
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
                            Visibility(
                              visible: umurBln == 24
                                  ? selectedPengukuran.isNotEmpty
                                  : true,
                              child: textfield(
                                  fem,
                                  umurBln > 24
                                      ? 'Tinggi Badan'
                                      : umurBln == 24
                                          ? selectedPengukuran ==
                                                  'Dikukur Terlentang'
                                              ? 'Panjang Badan'
                                              : 'Tinggi Badan'
                                          : 'Panjang Badan',
                                  tinggi_badan),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ExpansionTile(
                                title: Text(
                                  'Hasil Pengukuran Terakhir ${setTgl(dataAnak.pengukuranTerakhir)}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                childrenPadding:
                                    const EdgeInsets.only(left: 20),
                                children: [
                                  Visibility(
                                    visible: umurBln < 60,
                                    child: ListTile(
                                        onTap: () => HitungGizi()
                                            .beratBadanperUmur(
                                                context: context,
                                                dataAnak: dataAnak,
                                                list_bb_umur: list_bb_umur,
                                                umurBln: umurBln),
                                        title: const Text(
                                            'Hasil Berat Badan Menurut Umur (BB/U)')),
                                  ),
                                  Visibility(
                                    visible: umurBln < 60,
                                    child: ListTile(
                                        onTap: () => HitungGizi()
                                            .tinggibadanUmur(
                                                context: context,
                                                dataAnak: dataAnak,
                                                umurBln: umurBln,
                                                list_tb_umur: list_tb_umur,
                                                selectedPengukuran:
                                                    selectedPengukuran),
                                        title: Text(umurBln > 24
                                            ? 'Hasil Tinggi Badan Menurut Umur (TB/U)'
                                            : umurBln == 24
                                                ? selectedPengukuran ==
                                                        'Dikukur Terlentang'
                                                    ? 'Hasil Panjang Badan Menurut Umur (PB/U)'
                                                    : 'Hasil Tinggi Badan Menurut Umur (TB/U)'
                                                : 'Hasil Panjang Badan Menurut Umur (PB/U)')),
                                  ),
                                  Visibility(
                                    visible: umurBln < 60,
                                    child: ListTile(
                                        onTap: () {
                                          if (umurBln >= 24) {
                                            HitungGizi().beratTinggiBadan(
                                                context: context,
                                                dataAnak: dataAnak,
                                                umurBln: umurBln,
                                                list_bb_tb: list_bb_tb);
                                          } else {
                                            HitungGizi().beratPanjangBadan(
                                                context: context,
                                                dataAnak: dataAnak,
                                                umurBln: umurBln,
                                                list_bb_pb: list_bb_pb);
                                          }
                                        },
                                        title: FittedBox(
                                          fit: BoxFit.fitWidth,
                                          child: Text(umurBln >= 24
                                              ? 'Hasil Berat Badan Menurut Tinggi Badan (BB/TB)'
                                              : 'Hasil Berat Badan Menurut Panjang Badan (BB/PB)'),
                                        )),
                                  ),
                                  ListTile(
                                      onTap: () {
                                        if (umurBln >= 60) {
                                          HitungGizi().imtUmur518(
                                              context: context,
                                              dataAnak: dataAnak,
                                              umurBln: umurBln,
                                              list_imt_umur_518:
                                                  list_imt_umur_518,
                                              umurTahun: umurTahun);
                                        } else {
                                          HitungGizi().imtUmur(
                                              context: context,
                                              dataAnak: dataAnak,
                                              umurBln: umurBln,
                                              list_imt_umur: list_imt_umur);
                                        }
                                      },
                                      title: const Text(
                                          'Indeks Massa Tubuh Menurut Umur (IMT/U)')),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom /
                                          2),
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
                            showDialog(
                              context: context,
                              builder: (context) {
                                return PopUpConfirm(
                                  btnConfirmText: 'Simpan',
                                  btnCancelText: 'Batal',
                                  title: 'Simpan Data Pertumbuhan',
                                  message: 'Simpan Data Pertumbuhan',
                                  onPressed: () async {
                                    await updateDataAnak();
                                  },
                                );
                              },
                            );
                          },
                          child: Center(
                            child: Text(
                              'Simpan',
                              style: TextStyle(fontSize: 16 * ffem,color: Colors.white),
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

  TextFormField textfield(
      double fem, String label, TextEditingController controller) {
    return TextFormField(
        controller: controller,
        readOnly: label != 'Umur' ? false : true,
        keyboardType: label != 'Umur'
            ? const TextInputType.numberWithOptions(decimal: true)
            : null,
        inputFormatters: label != 'Umur'
            ? [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ]
            : [],
        decoration: InputDecoration(
            labelText: label,
            suffixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: label != 'Umur'
                ? Text(
                    label == 'Berat Badan' ? ' |\tKg\t\t' : ' |\tCm\t\t',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  )
                : null,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8))));
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

  Container data_anak(double fem, double ffem) {
    return Container(
      margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 13 * fem),
      padding: EdgeInsets.fromLTRB(12 * fem, 10 * fem, 12 * fem, 10 * fem),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xfff0f0f0)),
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * fem),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0f1b253e),
            offset: Offset(0 * fem, 2 * fem),
            blurRadius: 3.5 * fem,
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 8 * fem, 0 * fem),
        width: double.infinity,
        height: 57 * fem,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0 * fem, 0 * fem, 12 * fem, 0 * fem),
              width: 56 * fem,
              height: 56 * fem,
              child: Image.asset(
                "assets/images/group-1-jAH.png",
                width: 56 * fem,
                height: 56 * fem,
              ),
            ),
            Expanded(
              child: Container(
                margin:
                    EdgeInsets.fromLTRB(0 * fem, 9.5 * fem, 0 * fem, 9.5 * fem),
                height: double.infinity,
                child: Column(
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
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(
                                    0 * fem, 0 * fem, 5 * fem, 1 * fem),
                                width: 8 * fem,
                                height: 8 * fem,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4 * fem),
                                  color: HitungGizi()
                                      .getStatusGizi(
                                          context: context,
                                          dataAnak: dataAnak,
                                          umurBln: umurBln,
                                          list_imt_umur_518: list_imt_umur_518,
                                          list_imt_umur: list_imt_umur,
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
                                              list_imt_umur: list_imt_umur,
                                              umurTahun: umurTahun)
                                          .status ??
                                      '',
                                  style: TextStyle(
                                    //fontSize: 16 * ffem,
                                    fontWeight: FontWeight.w400,
                                    height: 1.2125 * ffem / fem,
                                    color: const Color(0xff161f35),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      GetUmur().umur(tglLahir: dataAnak.tanggallahir ?? ''),
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
    );
  }
}
