// ignore_for_file: use_build_context_synchronously

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:stunt_application/pages/Akun/akun.dart';
import 'package:stunt_application/pages/Home/home.dart';
import 'package:stunt_application/pages/Imunisasi/imunisasi.dart';
import 'package:stunt_application/pages/Konsultasi/konsultasi.dart';

import 'Bloc/AllBloc/all_bloc.dart';
import 'Bloc/KonsultasiBloc/konsultasiBloc.dart';
import 'Bloc/LogIn/login_bloc.dart';
import 'models/data_anak_model.dart';
import 'models/user.dart';
import 'utils/SessionManager.dart';
import 'utils/config.dart';

class Navigationbar extends StatefulWidget {
  final int index;
  const Navigationbar({super.key, required this.index});
  static const route = '/chat-list';

  @override
  State<Navigationbar> createState() => _NavigationbarState();
}

class _NavigationbarState extends State<Navigationbar> {
  int selectedIndex = 0;
  String token = '';
  User user = User();
  final screens = [
    const Home(),
    const Imunisasi(),
    const Konsultasi(),
    const Akun()
  ];
  DataAnakModel dataAnak = DataAnakModel();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      token = await SessionManager.getToken() ?? '';
      user = await SessionManager.getUser();
      dataAnak = await SessionManager.getDataAnak();
      await fetchdata();
      Duration duration = token.isNotEmpty
          ? JwtDecoder.getRemainingTime(token)
          : const Duration(minutes: 0);
      Configs().startSessionTimer(context, context.read<LoginBloc>(), duration);
      RemoteMessage? message =
          ModalRoute.of(context)!.settings.arguments as RemoteMessage?;
      setState(() {
        selectedIndex = message == null ? widget.index : 2;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchdata() async {
    await context.read<AllBloc>().getDataAnak(user: user, token: token);
    await context.read<AllBloc>().getDataTabelStatusGizi(
        jenisKelamin: dataAnak.jeniskelamin ?? '', token: token);
    if (dataAnak.id_anak != null) {
      await context.read<AllBloc>().getDetailDataAnak(
          user: user, id_anak: dataAnak.id_anak ?? '', token: token);
      await context.read<AllBloc>().getListJadwalVaksin(
          userID: user.userID ?? '',
          id_anak: dataAnak.id_anak ?? '',
          token: token);
    }
    String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await context.read<AllBloc>().getMenuMakan(
        userID: user.userID ?? '',
        id_anak: dataAnak.id_anak ?? '',
        tanggal: selectedDate,
        token: token);
    await context.read<AllBloc>().getRekomendasiMenu(token: token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType
            .fixed, // This ensures that all labels are visible
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Imunisasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.ballot),
            label: 'Konsultasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: const Color(0xff3f7af6),
        unselectedItemColor: Colors.grey, // Color of unselected items
        backgroundColor: Colors.white,
        elevation: 3,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
      ),
    );
  }
}
