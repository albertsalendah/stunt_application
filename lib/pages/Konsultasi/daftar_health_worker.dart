// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stunt_application/custom_widget/backbutton.dart';
import 'package:stunt_application/custom_widget/contact_card.dart';
import 'package:stunt_application/models/contact_model.dart';

import '../../Bloc/KonsultasiBloc/konsultasiBloc.dart';
import '../../Bloc/KonsultasiBloc/konsultasiState.dart';
import '../../models/user.dart';
import '../../utils/SessionManager.dart';

class DaftarHealthWorker extends StatefulWidget {
  const DaftarHealthWorker({super.key});

  @override
  State<DaftarHealthWorker> createState() => _DaftarHealthWorkerState();
}

class _DaftarHealthWorkerState extends State<DaftarHealthWorker> {
  User user = User();
  String token = '';
  List<Contact> listHealthWorker = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      user = await SessionManager.getUser();
      token = await SessionManager.getToken() ?? '';
      if (listHealthWorker.isEmpty) {
        await fetchData();
      }
    });
  }

  Future<void> fetchData() async {
    await context.read<KonsultasiBloc>().getDataHealthWorker();
  }

  List<Contact> get searchfilteredList {
    return listHealthWorker.where((item) {
      bool mNama = true;
      if (searchController.text.isNotEmpty) {
        mNama = item.nama
            .toString()
            .toLowerCase()
            .contains(searchController.text.toLowerCase());
      }
      return mNama;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375;
    double fem = MediaQuery.of(context).size.width / baseWidth;
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
              'Daftar Kontak',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16 * fem,
                  color: Colors.black),
            ),
            leading: CustomBackButton(fem: fem),
          ),
          body: BlocBuilder<KonsultasiBloc, KonsultasiState>(
            builder: (context, state) {
              if (state is DataInitialState) {
                return Center(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await fetchData();
                    },
                    child: ListView(children: [
                      SizedBox(
                          height: 40 * fem,
                          width: 40 * fem,
                          child: const CircularProgressIndicator()),
                      const SizedBox(
                        height: 8,
                      ),
                      const Text('Memuat Data')
                    ]),
                  ),
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
              } else if (state is HealthWorkerLoaded) {
                listHealthWorker = state.healthWorker;
                listHealthWorker.sort((a, b) {
                  return a.nama
                      .toString()
                      .toLowerCase()
                      .compareTo(b.nama.toString().toLowerCase());
                });
              }
              if (listHealthWorker.isEmpty) {
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
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'Search...',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 160,
                    child: RefreshIndicator(
                      onRefresh: () async {
                        await fetchData();
                      },
                      child: ListView.builder(
                        itemCount: searchfilteredList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ContactCard(contact: searchfilteredList[index]),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
