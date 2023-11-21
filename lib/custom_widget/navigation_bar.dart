// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:stunt_application/pages/Akun/akun.dart';
import 'package:stunt_application/pages/Home/home.dart';
import 'package:stunt_application/pages/Imunisasi/imunisasi.dart';
import 'package:stunt_application/pages/Konsultasi/konsultasi.dart';

import '../Bloc/KonsultasiBloc/konsultasiBloc.dart';
import '../Bloc/LogIn/login_bloc.dart';
import '../models/user.dart';
import '../utils/SessionManager.dart';
import '../utils/config.dart';

class Navigationbar extends StatefulWidget {
  final int index;
  const Navigationbar({super.key, required this.index});

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      token = await SessionManager.getToken() ?? '';
      user = await SessionManager.getUser();
     // await fetchData();
      Duration duration = token.isNotEmpty
          ? JwtDecoder.getRemainingTime(token)
          : const Duration(minutes: 0);
      Configs().startSessionTimer(context, context.read<LoginBloc>(), duration);
      setState(() {
        selectedIndex = widget.index;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchData() async {
    await context.read<KonsultasiBloc>().getDataHealthWorker(token: token);
    await context
        .read<KonsultasiBloc>()
        .getLatestMesage(userID: user.userID.toString(), token: token);
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
