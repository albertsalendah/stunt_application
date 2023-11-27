import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stunt_application/Bloc/AllBloc/all_bloc.dart';
import 'package:stunt_application/Bloc/LogIn/login_state.dart';
import 'package:stunt_application/Bloc/SocketBloc/socket_bloc.dart';
import 'package:stunt_application/firebase_options.dart';
import 'package:stunt_application/pages/Login_Register/login.dart';
import 'package:stunt_application/utils/firebase_api.dart';
import 'package:stunt_application/utils/sqlite_helper.dart';
import 'package:stunt_application/utils/vaksin_notification.dart';
import 'Bloc/KonsultasiBloc/konsultasiBloc.dart';
import 'Bloc/LogIn/login_bloc.dart';
import 'navigation_bar.dart';
import 'package:timezone/data/latest_all.dart' as tz;

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi().initPushNotifications();
  await FirebaseApi().initLocalNotification();
  await SqliteHelper().database;
  await VaksinNotification().initNotifications();
  tz.initializeTimeZones();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AllBloc()),
        BlocProvider(create: (context) => LoginBloc()),
        BlocProvider(create: (context) => SocketProviderBloc()),
        BlocProvider(create: (context) => KonsultasiBloc()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;
  bool isSessionExpired = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<LoginBloc>().isLogIn();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        if (state is LoginInitial) {
        } else if (state is LoginErrorState) {
        } else if (state is LoggedInState) {
          isLoggedIn = state.isLoggedIn;
          isSessionExpired = state.isSessionExpired;
        }
        log(' Is User Loggedin : ${isLoggedIn && !isSessionExpired}');
        if (isLoggedIn && !isSessionExpired) {
          return MaterialApp(
              navigatorKey: navigatorKey,
              theme: ThemeData(
                useMaterial3: false,
              ),
              routes: {
                Navigationbar.route: (context) => const Navigationbar(index: 0)
              },
              home: const Navigationbar(index: 0));
        } else {
          return MaterialApp(
              theme: ThemeData(
                useMaterial3: false,
              ),
              home: const Login());
        }
      },
    );
  }
}
