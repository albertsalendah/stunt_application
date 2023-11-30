// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'dart:developer';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:stunt_application/custom_widget/popUpConfirm.dart';
import 'package:stunt_application/custom_widget/popUpLoading.dart';
import 'package:stunt_application/custom_widget/popup_success.dart';
import 'package:stunt_application/models/api_massage.dart';
import 'package:stunt_application/models/user.dart';
import 'package:stunt_application/pages/Data_Anak/data_anak_api.dart';
import '../../Bloc/AllBloc/all_bloc.dart';
import '../../Bloc/AllBloc/all_state.dart';
import '../../navigation_bar.dart';
import '../../custom_widget/popup_error.dart';
import '../../models/data_anak_model.dart';
import '../../utils/SessionManager.dart';
import '../../utils/formatTgl.dart';

class DataAnak extends StatefulWidget {
  final bool afterRegister;
  const DataAnak({
    super.key,
    required this.afterRegister,
  });

  @override
  State<DataAnak> createState() => _DataAnakState();
}

class _DataAnakState extends State<DataAnak> {
  DataAnakApi api = DataAnakApi();
  User user = User();
  String token = '';
  bool enable = false;
  bool tambah = false;
  TextEditingController nama_anak = TextEditingController();
  TextEditingController tgl_lahir = TextEditingController();
  TextEditingController berat_badan = TextEditingController();
  TextEditingController panjang_badan = TextEditingController();
  TextEditingController lingkar_kepala = TextEditingController();
  String selected_gender = '';
  DataAnakModel dataAnak = DataAnakModel();
  FocusNode btnFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();
  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  List<GlobalKey<FormState>> keys =
      List.generate(6, (index) => GlobalKey<FormState>());
  List<String> gender = ['Laki-Laki', 'Perempuan'];

  final GlobalKey<State> tambahDataAnakLoadingKey = GlobalKey<State>();
  final GlobalKey<State> updateDataAnakLoadingKey = GlobalKey<State>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      user = await fetch_user();
      token = await SessionManager.getToken() ?? '';
      dataAnak = await SessionManager.getDataAnak();
      await fetchData(user, token);
      if (!widget.afterRegister) {
        if (dataAnak.namaanak != null && dataAnak.namaanak!.isNotEmpty) {
          enable = false;
          setData();
        } else {
          await fetchData(user, token);
          setData();
          enable =
              !(dataAnak.namaanak != null && dataAnak.namaanak!.isNotEmpty);
        }
      } else {
        tambah = true;
        enable = true;
      }
      setState(() {
        selected_gender = gender.first;
      });
    });
  }

  @override
  void dispose() {
    btnFocus.dispose();
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

  void clearfield() {
    nama_anak.text = '';
    tgl_lahir.text = '';
    berat_badan.text = '';
    panjang_badan.text = '';
    lingkar_kepala.text = '';
    selected_gender = gender.first;
  }

  Future<void> fetchData(User user, String token) async {
    dataAnak = await SessionManager.getDataAnak();
    await context.read<AllBloc>().getDataAnak(user: user, token: token);
    await context.read<AllBloc>().getDetailDataAnak(
        user: user, id_anak: dataAnak.id_anak ?? '', token: token);
  }

  Future<User> fetch_user() async {
    return await SessionManager.getUser();
  }

  Future<void> setData() async {
    if (dataAnak.id_anak != null) {
      nama_anak.text = dataAnak.namaanak ?? '';
      selected_gender = dataAnak.jeniskelamin ?? '';
      tgl_lahir.text = FormatTgl().setTgl(dataAnak.tanggallahir);
      berat_badan.text = dataAnak.beratbadan.toString();
      panjang_badan.text = dataAnak.tinggibadan.toString();
      lingkar_kepala.text = dataAnak.lingkarkepala.toString();
    }
  }

  Future<void> addDataAnak(BuildContext contextConfirm) async {
    if (user.userID != null &&
        '${user.userID}'.isNotEmpty &&
        token.isNotEmpty &&
        nama_anak.text.isNotEmpty &&
        tgl_lahir.text.isNotEmpty &&
        berat_badan.text.isNotEmpty &&
        panjang_badan.text.isNotEmpty &&
        lingkar_kepala.text.isNotEmpty &&
        selected_gender.isNotEmpty) {
      Navigator.pop(contextConfirm);
      showDialog(
        context: context,
        builder: (loadcontext) => PopUpLoading(
          key: tambahDataAnakLoadingKey,
        ),
      );
      try {
        await api
            .addDataAnak(
                userID: user.userID ?? '',
                namaAnak: nama_anak.text,
                jenisKelamin: selected_gender,
                tanggalLahir: FormatTgl().format_tanggal(tgl_lahir.text),
                beratbadan: berat_badan.text,
                tinggibadan: panjang_badan.text,
                lingkarkepala: lingkar_kepala.text,
                token: token)
            .then((result) {
          Navigator.of(tambahDataAnakLoadingKey.currentContext ?? context)
              .pop();
          if (result.status) {
            showDialog(
              context: context,
              builder: (context) => PopUpSuccess(message: result.message ?? ''),
            ).then((value) {
              clearfield();
              fetchData(user, token);
              enable = false;
            });
          } else {
            showDialog(
              context: context,
              builder: (context) => PopUpError(message: result.message ?? ''),
            );
          }
        });
      } catch (error) {
        log('Error Tambah Data Anak -> $error');
        Navigator.of(tambahDataAnakLoadingKey.currentContext ?? context).pop();
        showDialog(
          context: context,
          builder: (context) => const PopUpError(
              message: 'Terjadi Kesalahan Saat Menambahkan Data Anak'),
        );
      }
    }
  }

  Future<void> updateDataAnak(BuildContext contextConfirm) async {
    if (user.userID != null &&
        '${user.userID}'.isNotEmpty &&
        token.isNotEmpty &&
        nama_anak.text.isNotEmpty &&
        tgl_lahir.text.isNotEmpty &&
        berat_badan.text.isNotEmpty &&
        panjang_badan.text.isNotEmpty &&
        lingkar_kepala.text.isNotEmpty &&
        selected_gender.isNotEmpty) {
      Navigator.pop(contextConfirm);
      showDialog(
        context: context,
        builder: (loadcontext) => PopUpLoading(
          key: updateDataAnakLoadingKey,
        ),
      );
      try {
        await api
            .updateDataAnak(
                id_anak: dataAnak.id_anak ?? '',
                userID: user.userID ?? '',
                namaAnak: nama_anak.text,
                jenisKelamin: selected_gender,
                tanggalLahir: FormatTgl().format_tanggal(tgl_lahir.text),
                beratbadan: berat_badan.text,
                tinggibadan: panjang_badan.text,
                lingkarkepala: lingkar_kepala.text,
                token: token)
            .then((result) {
          Navigator.of(updateDataAnakLoadingKey.currentContext ?? context)
              .pop();
          if (result.status) {
            showDialog(
              context: context,
              builder: (context) => PopUpSuccess(message: result.message ?? ''),
            ).then((_) {
              clearfield();
              fetchData(user, token);
              enable = false;
            });
          } else {
            showDialog(
              context: context,
              builder: (context) => PopUpError(message: result.message ?? ''),
            );
          }
        });
      } catch (error) {
        log('Error Tambah Data Anak -> $error');
        Navigator.of(updateDataAnakLoadingKey.currentContext ?? context).pop();
        showDialog(
          context: context,
          builder: (context) => const PopUpError(
              message: 'Terjadi Kesalahan Saat Menambahkan Data Anak'),
        );
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
            appBar: AppBar(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                iconTheme: const IconThemeData(color: Colors.grey),
                title: Text(
                  'Data dasar anak',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16 * fem,
                      color: Colors.black),
                ),
                leading: backbutton(fem, context)),
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: false,
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
                  if (!widget.afterRegister) {
                    if (!enable) {
                      setData();
                    }
                  }
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: [
                    const SizedBox(
                      height: 16,
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await fetchData(user, token);
                          setData();
                        },
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          reverse: false,
                          child: Column(children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Nama anak'),
                                  ),
                                  Focus(
                                    key: keys[0],
                                    focusNode: focusNodes[0],
                                    child: TextFormField(
                                      controller: nama_anak,
                                      enabled: enable,
                                      onEditingComplete: () {
                                        focusNodes[1].requestFocus();
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'nama lengkap anak',
                                        prefixIconConstraints:
                                            const BoxConstraints(
                                                minWidth: 0, minHeight: 0),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Jenis Kelamin'),
                                  ),
                                  Focus(
                                    key: keys[1],
                                    focusNode: focusNodes[1],
                                    child: DropdownMenu<String>(
                                      enabled: enable,
                                      width: MediaQuery.of(context).size.width -
                                          30,
                                      inputDecorationTheme:
                                          InputDecorationTheme(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      onSelected: (String? value) {
                                        setState(() {
                                          if (value != null) {
                                            selected_gender = value;
                                          }
                                        });
                                        focusNodes[2].requestFocus();
                                      },
                                      initialSelection: dataAnak.id_anak != null
                                          ? gender.firstWhere((element) =>
                                              element == dataAnak.jeniskelamin)
                                          : gender.first,
                                      dropdownMenuEntries: gender
                                          .map<DropdownMenuEntry<String>>(
                                              (String value) {
                                        return DropdownMenuEntry<String>(
                                            value: value, label: value);
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Tanggal Lahir'),
                                  ),
                                  Focus(
                                    key: keys[2],
                                    focusNode: focusNodes[2],
                                    child: TextField(
                                        controller: tgl_lahir,
                                        enabled: enable,
                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            suffixIcon:
                                                Icon(Icons.calendar_today),
                                            hintText: 'Masukkan tanggal lahir'),
                                        readOnly: true,
                                        onTap: () async {
                                          DateTime? pickedDate =
                                              await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(1960),
                                                  lastDate: DateTime(2101));
                                          if (pickedDate != null) {
                                            String formattedDate =
                                                DateFormat('dd MMMM yyyy')
                                                    .format(pickedDate);
                                            setState(() {
                                              tgl_lahir.text = formattedDate;
                                              focusNodes[3].requestFocus();
                                            });
                                          }
                                        }),
                                  )
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Flexible(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Berat Badan'),
                                        ),
                                        Focus(
                                          key: keys[3],
                                          focusNode: focusNodes[3],
                                          onFocusChange: (hasFocus) {
                                            if (hasFocus) {
                                              autoScroll(keys[3]);
                                            }
                                          },
                                          child: TextFormField(
                                            controller: berat_badan,
                                            enabled: enable,
                                            onEditingComplete: () =>
                                                focusNodes[4].requestFocus(),
                                            onChanged: (value) {
                                              autoScroll(keys[3]);
                                            },
                                            keyboardType: const TextInputType
                                                .numberWithOptions(
                                                decimal: true),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'^\d*\.?\d*')),
                                            ],
                                            decoration: InputDecoration(
                                              hintText: '0',
                                              suffixIconConstraints:
                                                  const BoxConstraints(
                                                      minWidth: 0,
                                                      minHeight: 0),
                                              suffixIcon: const Text(
                                                ' | Kg ',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.grey),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text('Panjang badan'),
                                        ),
                                        Focus(
                                          key: keys[4],
                                          focusNode: focusNodes[4],
                                          onFocusChange: (hasFocus) {
                                            if (hasFocus) {
                                              autoScroll(keys[4]);
                                            }
                                          },
                                          child: TextFormField(
                                            controller: panjang_badan,
                                            enabled: enable,
                                            onEditingComplete: () =>
                                                focusNodes[5].requestFocus(),
                                            onChanged: (value) {
                                              autoScroll(keys[4]);
                                            },
                                            keyboardType: const TextInputType
                                                .numberWithOptions(
                                                decimal: true),
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'^\d*\.?\d*')),
                                            ],
                                            decoration: InputDecoration(
                                              hintText: '0',
                                              suffixIconConstraints:
                                                  const BoxConstraints(
                                                      minWidth: 0,
                                                      minHeight: 0),
                                              suffixIcon: const Text(
                                                ' | Cm ',
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.grey),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Lingkar Kepala'),
                                  ),
                                  Focus(
                                    key: keys[5],
                                    focusNode: focusNodes[5],
                                    onFocusChange: (hasFocus) {
                                      autoScroll(keys[5]);
                                    },
                                    child: TextFormField(
                                      controller: lingkar_kepala,
                                      enabled: enable,
                                      onEditingComplete: () =>
                                          btnFocus.requestFocus(),
                                      onChanged: (value) {
                                        autoScroll(keys[5]);
                                      },
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: true),
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'^\d*\.?\d*')),
                                      ],
                                      decoration: InputDecoration(
                                        hintText: '0',
                                        suffixIconConstraints:
                                            const BoxConstraints(
                                                minWidth: 0, minHeight: 0),
                                        suffixIcon: const Text(
                                          ' | Cm ',
                                          style: TextStyle(
                                              fontSize: 18, color: Colors.grey),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom /
                                          1.8),
                            )
                          ]),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Visibility(
                                  visible: !widget.afterRegister,
                                  child: addButton(fem, context)),
                              Expanded(
                                child: Container(
                                  height: 60,
                                  margin: const EdgeInsets.all(10),
                                  padding:
                                      const EdgeInsets.only(bottom: 5, top: 5),
                                  child: ElevatedButton(
                                    focusNode: btnFocus,
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        backgroundColor:
                                            const Color(0xff3f7af6)),
                                    onPressed: () {
                                      if (nama_anak.text.isNotEmpty &&
                                          tgl_lahir.text.isNotEmpty &&
                                          berat_badan.text.isNotEmpty &&
                                          panjang_badan.text.isNotEmpty &&
                                          lingkar_kepala.text.isNotEmpty &&
                                          selected_gender.isNotEmpty) {
                                        if (tambah) {
                                          showDialog(
                                            context: context,
                                            builder: (contextConfirm) =>
                                                PopUpConfirm(
                                              btnConfirmText: 'Simpan',
                                              btnCancelText: 'Batal',
                                              title: 'Simpan Data Anak',
                                              message: 'Simpan Data Anak?',
                                              onPressed: () async {
                                                await addDataAnak(
                                                    contextConfirm);
                                                if (widget.afterRegister) {
                                                  await checkUser();
                                                }
                                              },
                                            ),
                                          );
                                        } else {
                                          if (dataAnak.id_anak != null &&
                                              dataAnak.id_anak
                                                  .toString()
                                                  .isNotEmpty) {
                                            showDialog(
                                              context: context,
                                              builder: (contextConfirm) =>
                                                  PopUpConfirm(
                                                btnConfirmText: 'Ubah',
                                                btnCancelText: 'Batal',
                                                title: 'Ubah Data Anak',
                                                message: 'Ubah Data Anak?',
                                                onPressed: () async {
                                                  await updateDataAnak(
                                                      contextConfirm);
                                                },
                                              ),
                                            );
                                          } else {
                                            showDialog(
                                              context: context,
                                              builder: (contextConfirm) =>
                                                  PopUpConfirm(
                                                btnConfirmText: 'Simpan',
                                                btnCancelText: 'Batal',
                                                title: 'Simpan Data Anak',
                                                message: 'Simpan Data Anak?',
                                                onPressed: () async {
                                                  await addDataAnak(
                                                      contextConfirm);
                                                  if (widget.afterRegister) {
                                                    await checkUser();
                                                  }
                                                },
                                              ),
                                            );
                                          }
                                        }
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              const PopUpError(
                                                  message: 'Isi Semua Kolom'),
                                        ).then((value) {
                                          if (nama_anak.text.isEmpty) {
                                            focusNodes[0].requestFocus();
                                          } else if (tgl_lahir.text.isEmpty) {
                                            focusNodes[2].requestFocus();
                                          } else if (berat_badan.text.isEmpty) {
                                            focusNodes[3].requestFocus();
                                          } else if (panjang_badan
                                              .text.isEmpty) {
                                            focusNodes[4].requestFocus();
                                          } else if (lingkar_kepala
                                              .text.isEmpty) {
                                            focusNodes[5].requestFocus();
                                          }
                                        });
                                      }
                                    },
                                    child: Center(
                                      child: Text(
                                        (widget.afterRegister)
                                            ? 'Selanjutnya'
                                            : !tambah
                                                ? dataAnak.id_anak != null
                                                    ? 'Update'
                                                    : 'Simpan'
                                                : 'Simpan',
                                        style: TextStyle(
                                            fontSize: 16 * ffem,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: !widget.afterRegister &&
                                    dataAnak.id_anak != null,
                                child: editButton(fem, context),
                              ),
                            ],
                          ),
                          Visibility(
                            visible: widget.afterRegister,
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 14 * ffem,
                                  fontWeight: FontWeight.w400,
                                  height: 1.2125 * ffem / fem,
                                  color: const Color(0xff707070),
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Skip tahap ini',
                                    style: TextStyle(
                                      fontSize: 14 * ffem,
                                      height: 1.2125 * ffem / fem,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        await checkUser();
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                );
              },
            )),
      ),
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
            onPressed: () async {
              await checkUser();
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.grey,
              size: 16 * fem,
            )),
      ),
    );
  }

  Container addButton(double fem, BuildContext context) {
    return Container(
      height: 50 * fem,
      width: 50 * fem,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffe2e2e2)),
        color: const Color(0xffffffff),
        borderRadius: BorderRadius.circular(10 * fem),
      ),
      child: IconButton(
          onPressed: () async {
            setState(() {
              enable = true;
              tambah = true;
              clearfield();
              dataAnak = DataAnakModel();
            });
          },
          icon: Icon(
            Icons.add_circle,
            color: Colors.grey,
            size: 24 * fem,
          )),
    );
  }

  Container editButton(double fem, BuildContext context) {
    return Container(
      height: 50 * fem,
      width: 50 * fem,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffe2e2e2)),
        color: const Color(0xffffffff),
        borderRadius: BorderRadius.circular(10 * fem),
      ),
      child: IconButton(
          onPressed: () async {
            setState(() {
              enable = !enable;
              tambah = false;
            });
          },
          icon: Icon(
            Icons.edit,
            color: Colors.grey,
            size: 24 * fem,
          )),
    );
  }

  Future<void> checkUser() async {
    if (widget.afterRegister) {
      final isLoggedIn = await SessionManager.isUserLoggedIn();
      final isSessionExpired = await SessionManager.isSessionExpired();
      try {
        if (isLoggedIn == true && isSessionExpired == false) {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const Navigationbar(
                      index: 0,
                    )),
          );
        }
      } catch (e) {
        log(e.toString());
      }
    } else {
      Navigator.pop(context);
    }
  }
}
