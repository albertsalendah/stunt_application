// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stunt_application/custom_widget/chat_card.dart';
import 'package:stunt_application/models/message_model.dart';
import 'package:stunt_application/pages/Konsultasi/daftar_health_worker.dart';

import '../../Bloc/KonsultasiBloc/konsultasiBloc.dart';
import '../../Bloc/KonsultasiBloc/konsultasiState.dart';
import '../../custom_widget/blue_header_02.dart';
import '../../navigation_bar.dart';
import '../../models/user.dart';
import '../../utils/SessionManager.dart';

class Konsultasi extends StatefulWidget {
  const Konsultasi({super.key});

  @override
  State<Konsultasi> createState() => _KonsultasiState();
}

class _KonsultasiState extends State<Konsultasi> {
  User user = User();
  String token = '';
  List<MessageModel> listMessage = [];
  List<MessageModel> listAllUnread = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      user = await SessionManager.getUser();
      token = await SessionManager.getToken() ?? '';
      await fetchData();
      if (listMessage.isEmpty) {
        await fetchData();
      }
    });
  }

  Future<void> fetchData() async {
    await context
        .read<KonsultasiBloc>()
        .getLatestMesage(userID: user.userID.toString());
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
          backgroundColor: Colors.white,
          appBar: AppBar(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              iconTheme: const IconThemeData(color: Colors.grey),
              title: Text(
                'Konsultasi Gizi',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16 * fem,
                    color: Colors.black),
              ),
              leading: backbutton(fem, context)),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              const Blue_Header_02(
                  text1: 'Konsultasikan Gizi Secara Gratis',
                  text2: 'Komunikasikan Secara Live'),
              const SizedBox(
                height: 16,
              ),
              con(fem, ffem),
              const SizedBox(
                height: 16,
              ),
              BlocBuilder<KonsultasiBloc, KonsultasiState>(
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
                  } else if (state is ListLatestMesasage) {
                    listMessage = state.listLatestMessage
                        .where((element) =>
                            element.conversationId !=
                            '${user.userID}-${user.userID}')
                        .toList();
                    listMessage.sort((a, b) {
                      DateTime dateTimeA = DateTime.parse('${a.tanggalkirim}');
                      DateTime dateTimeB = DateTime.parse('${b.tanggalkirim}');
                      return dateTimeB.compareTo(dateTimeA);
                    });
                    listAllUnread = state.listAllUnread;
                  }
                  return Expanded(
                    child: SizedBox(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await fetchData();
                        },
                        child: ListView.builder(
                          itemCount: listMessage.length,
                          itemBuilder: (context, index) {
                            var count = listAllUnread.where((element) =>
                                element.conversationId ==
                                listMessage[index].conversationId);
                            return Column(
                              children: [
                                ChatCard(
                                  messageModel: listMessage[index],
                                  totalUnread: count.length,
                                ),
                                const SizedBox(
                                  height: 8,
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ]),
          ),
        ),
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
            )),
      ),
    );
  }

  Row con(double fem, double ffem) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Container(
            margin: EdgeInsets.fromLTRB(0 * fem, 0.5 * fem, 108 * fem, 0 * fem),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin:
                      EdgeInsets.fromLTRB(0 * fem, 0 * fem, 0 * fem, 2 * fem),
                  child: Text(
                    'List pakar konsultan Gizi',
                    style: TextStyle(
                      fontSize: 14 * ffem,
                      fontWeight: FontWeight.w600,
                      height: 1.2125 * ffem / fem,
                      color: const Color(0xff161f35),
                    ),
                  ),
                ),
                Text(
                  'Pilih pakar & lakukan konsultasi',
                  style: TextStyle(
                    fontSize: 12 * ffem,
                    fontWeight: FontWeight.w400,
                    height: 1.6666666667 * ffem / fem,
                    color: const Color(0xff707070),
                  ),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const DaftarHealthWorker()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Container(
                width: 35 * fem,
                height: 35 * fem,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(
                  Icons.list,
                  color: Colors.grey,
                )),
          ),
        ),
      ],
    );
  }
}
