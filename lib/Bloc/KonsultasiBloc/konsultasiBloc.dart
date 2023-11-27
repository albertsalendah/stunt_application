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

  getDataHealthWorker() async {
    List<User> healthWorker = await konsultasiAPI.getListHealthWorker();
    emit(HealthWorkerLoaded(healthWorker));
  }

  getLatestMesage({required String userID}) async {
    List<MessageModel> list =
        await konsultasiAPI.getListLatestMessage(userID: userID);
    List<MessageModel> list2 = await sqlite.countUnRead();
    emit(ListLatestMesasage(list, list2));
  }

  getIndividualMessage(
      {required String senderID, required String receiverID}) async {
    List<MessageModel> list = await konsultasiAPI.getIndividualMessage(
        senderID: senderID, receiverID: receiverID);
    emit(ListIndividualMesasage(list));
  }
}
