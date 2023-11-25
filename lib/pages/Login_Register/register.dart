// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stunt_application/custom_widget/popUpConfirmCode.dart';
import 'package:stunt_application/custom_widget/popUpLoading.dart';
import 'package:stunt_application/models/user.dart';
import 'package:stunt_application/pages/Data_Anak/data_anak.dart';
import 'package:stunt_application/pages/Login_Register/login.dart';
import 'package:stunt_application/pages/Login_Register/login_register_api.dart';
import 'package:stunt_application/pages/LupaPassword/lupa_password_api.dart';
import 'package:stunt_application/utils/random_String.dart';
import 'dart:math' as math;
import '../../custom_widget/blue_header_01.dart';
import '../../custom_widget/popup_error.dart';
import '../../custom_widget/popup_success.dart';
import '../../models/api_massage.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool passwordVisible = false;
  Login_Register_Api api = Login_Register_Api();
  LupaPasswordApi apiPass = LupaPasswordApi();
  TextEditingController nama = TextEditingController();
  TextEditingController no_wa = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();
  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  List<PlatformFile> picked_foto = [];
  Uint8List? imagebytes;
  String foto = '';
  final ScrollController _scrollController = ScrollController();
  List<GlobalKey<FormState>> keys =
      List.generate(5, (index) => GlobalKey<FormState>());

  void clear_field() {
    nama.text = '';
    no_wa.text = '';
    email.text = '';
    pass.text = '';
  }

  @override
  void dispose() {
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

  void pickPicture() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: false, type: FileType.image, withData: true);

      if (result != null && result.files.single.path != null) {
        picked_foto = result.files;
        String? mimeType = lookupMimeType(picked_foto.first.name);
        double sizeInMB = picked_foto.first.size / math.pow(1024, 2);

        setState(() {
          if (mimeType?.startsWith('image') == true) {
            if (sizeInMB <= 11) {
              imagebytes = picked_foto.first.bytes;
              if (imagebytes != null) {
                foto = base64Encode(imagebytes!);
              }
            } else {
              showDialog(
                context: context,
                builder: (context) =>
                    const PopUpError(message: 'File Terlalu Besar (10 MB) MAX'),
              );
            }
          }
        });
      }
    } on Exception catch (e) {
      log(e.toString());
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
            body: Column(
              children: [
                const Blue_Header_01(
                    text1: 'Daftar Akun',
                    text2:
                        'Untuk mendaftarkan akun anda, silahkan mengisi data dibawah ini'),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom / 1.8),
                    reverse: false,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 16,
                        ),
                        GestureDetector(
                          onTap: () {
                            pickPicture();
                          },
                          child: imagebytes != null
                              ? CircleAvatar(
                                  radius: 45.0,
                                  backgroundImage: MemoryImage(imagebytes!),
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      width: 90,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(200),
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(65),
                                          bottomRight: Radius.circular(65),
                                        ),
                                      ),
                                      child: const Center(
                                          child: Text(
                                        'Foto',
                                        style: TextStyle(color: Colors.black),
                                      )),
                                    ),
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 45.0,
                                  backgroundImage: const AssetImage(
                                      'assets/images/group-115.png'),
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      width: 90,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(200),
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(65),
                                          bottomRight: Radius.circular(65),
                                        ),
                                      ),
                                      child: const Center(
                                          child: Text(
                                        'Foto',
                                        style: TextStyle(color: Colors.black),
                                      )),
                                    ),
                                  ),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Nama"),
                              ),
                              Focus(
                                onFocusChange: (hasFocus) {
                                  if (hasFocus) {
                                    autoScroll(keys[0]);
                                  }
                                },
                                child: TextFormField(
                                  key: keys[0],
                                  controller: nama,
                                  focusNode: focusNodes[0],
                                  onEditingComplete: () {
                                    focusNodes[1].requestFocus();
                                    autoScroll(keys[1]);
                                  },
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    hintText: 'masukkan nama lengkap',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
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
                                child: Text('No. WhatsApp'),
                              ),
                              Focus(
                                onFocusChange: (hasFocus) {
                                  if (hasFocus) {
                                    autoScroll(keys[1]);
                                  }
                                },
                                child: TextFormField(
                                  key: keys[1],
                                  controller: no_wa,
                                  focusNode: focusNodes[1],
                                  onEditingComplete: () {
                                    focusNodes[2].requestFocus();
                                    autoScroll(keys[2]);
                                  },
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  decoration: InputDecoration(
                                    hintText: 'No. WhatsApp',
                                    prefixIcon: const Padding(
                                      padding:
                                          EdgeInsets.only(left: 8, right: 5),
                                      child: Text(
                                        '+62 |',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    prefixIconConstraints: const BoxConstraints(
                                        minWidth: 0, minHeight: 0),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
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
                                child: Text('Email'),
                              ),
                              Focus(
                                onFocusChange: (hasFocus) {
                                  if (hasFocus) {
                                    autoScroll(keys[2]);
                                  }
                                },
                                child: TextFormField(
                                  key: keys[2],
                                  controller: email,
                                  focusNode: focusNodes[2],
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  onEditingComplete: () {
                                    focusNodes[3].requestFocus();
                                    autoScroll(keys[3]);
                                  },
                                  onChanged: (value) {
                                    autoScroll(keys[2]);
                                  },
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    hintText: 'Email',
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
                                      color: Colors.grey,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Silahkan isi email anda';
                                    } else if (!isValidEmail(value)) {
                                      return 'Format email salah';
                                    }
                                    return null;
                                  },
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
                                child: Text('Kata Sandi'),
                              ),
                              Focus(
                                onFocusChange: (hasFocus) {
                                  if (hasFocus) {
                                    autoScroll(keys[3]);
                                  }
                                },
                                child: TextFormField(
                                  key: keys[3],
                                  controller: pass,
                                  focusNode: focusNodes[3],
                                  onEditingComplete: () => FocusManager
                                      .instance.primaryFocus
                                      ?.unfocus(),
                                  onChanged: (value){
                                    autoScroll(keys[3]);
                                  },
                                  obscureText: !passwordVisible,
                                  decoration: InputDecoration(
                                    hintText: 'masukkan kata sandi',
                                    prefixIcon: const Icon(
                                      Icons.lock_outline,
                                      color: Colors.grey,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          passwordVisible = !passwordVisible;
                                        });
                                      },
                                      icon: Icon(
                                        !passwordVisible
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                          height: 60,
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.only(bottom: 10),
                          child: ElevatedButton(
                            focusNode: focusNodes[4],
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                backgroundColor: const Color(0xff3f7af6)),
                            onPressed: () async {
                              if (no_wa.text.isNotEmpty &&
                                  pass.text.isNotEmpty &&
                                  email.text.isNotEmpty &&
                                  nama.text.isNotEmpty) {
                                User check =
                                    await apiPass.getDataUser(noHp: no_wa.text);
                                if (check.userID != null &&
                                    check.userID!.isNotEmpty) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => const PopUpError(
                                        message: 'Nomer HP Sudah Terdaftar'),
                                  );
                                } else {
                                  sendConfirmEmail();
                                }
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) => const PopUpError(
                                      message: 'Isi Semua Kolom'),
                                ).then((value) {
                                  if (nama.text.isEmpty) {
                                    focusNodes[0].requestFocus();
                                  } else if (no_wa.text.isEmpty) {
                                    focusNodes[1].requestFocus();
                                  } else if (email.text.isEmpty) {
                                    focusNodes[2].requestFocus();
                                  } else if (pass.text.isEmpty) {
                                    focusNodes[3].requestFocus();
                                  }
                                });
                              }
                            },
                            child: Center(
                              child: Text(
                                'Daftar Sekarang',
                                style: TextStyle(
                                    fontSize: 16 * ffem, color: Colors.white),
                              ),
                            ),
                          )),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14 * ffem,
                            fontWeight: FontWeight.w400,
                            height: 1.2125 * ffem / fem,
                            color: const Color(0xff707070),
                          ),
                          children: [
                            const TextSpan(
                              text: 'Sudah punya akun? Masuk ',
                            ),
                            TextSpan(
                              text: 'disini',
                              style: TextStyle(
                                fontSize: 14 * ffem,
                                fontWeight: FontWeight.w700,
                                height: 1.2125 * ffem / fem,
                                color: const Color(0xff3f7af6),
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Login()),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$');
    return emailRegex.hasMatch(email);
  }

  void sendConfirmEmail() async {
    String code = RandomString().makeId(6);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const PopUpLoading();
        });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('randomCode', code);
    bool result = await apiPass.sendEmail(
        to: email.text, code: code, subject: 'Konfirmasi Email StuntApp');
    if (result) {
      Navigator.pop(context);
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (con) {
            return GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              child: PopUpConfirmCode(
                email: email.text,
                onPressed: (String code) {
                  SharedPreferences.getInstance().then((prefs) async {
                    String storedCode = prefs.getString('randomCode') ?? '';
                    if (code == storedCode) {
                      var conLoading;
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            conLoading = context;
                            return const PopUpLoading();
                          });
                      API_Message result = await api.registerUser(
                          nama: nama.text,
                          noHp: no_wa.text,
                          email: email.text,
                          password: pass.text,
                          foto: foto,
                          fcm_token: '');
                      Navigator.pop(conLoading);
                      if (result.status) {
                        Navigator.pop(con);
                        showDialog(
                            context: context,
                            builder: (context) => PopUpSuccess(
                                message: result.message.toString())).then(
                          (value) async {
                            API_Message result = await api.login(
                                noHp: no_wa.text, password: pass.text);
                            if (result.status) {
                              Navigator.pop(context);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DataAnak(afterRegister: true),
                                ),
                              );
                              prefs.remove('randomCode');
                              clear_field();
                            }
                          },
                        );
                      } else {
                        Navigator.pop(con);
                        showDialog(
                          context: context,
                          builder: (context) =>
                              PopUpError(message: result.message.toString()),
                        );
                        prefs.remove('randomCode');
                        clear_field();
                      }
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) => const PopUpError(
                              message: 'Kode yang anda masukkan salah'));
                    }
                  });
                },
              ),
            );
          });
    } else {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) =>
            const PopUpError(message: 'Email Tidak Ditemukan'),
      );
    }
  }
}
