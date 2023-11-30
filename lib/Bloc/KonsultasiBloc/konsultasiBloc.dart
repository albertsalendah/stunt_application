import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stunt_application/utils/sqlite_helper.dart';

import '../../models/message_model.dart';
import '../../models/user.dart';
import '../../pages/Konsultasi/konsultasi_api.dart';
import '../../utils/config.dart';
import 'konsultasiState.dart';

class KonsultasiBloc extends Cubit<KonsultasiState> {
  KonsultasiBloc() : super(DataInitialState());
  static const String link = Configs.LINK;
  SqliteHelper sqlite = SqliteHelper();
  KonsultasiAPI konsultasiAPI = KonsultasiAPI();

  Future<void> getDataHealthWorker() async {
    await konsultasiAPI.getListHealthWorker().then((list) {
      emit(HealthWorkerLoaded(list));
    });
  }

  Future<void> getLatestMesage({required String userID}) async {
    await sqlite.getListLatestMessage(userID: userID).then((list) async {
      await sqlite.countUnRead(userID).then((list2) {
        emit(ListLatestMesasage(list, list2));
      });
    });
  }

  Future<void> getIndividualMessage(
      {required String senderID, required String receiverID}) async {
    await sqlite
        .getIndividualMessage(senderID: senderID, receiverID: receiverID)
        .then((value) {
      emit(ListIndividualMesasage(value));
    });
  }
}
