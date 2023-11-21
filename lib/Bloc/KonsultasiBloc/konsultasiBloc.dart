import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/message_model.dart';
import '../../models/user.dart';
import '../../pages/Konsultasi/konsultasi_api.dart';
import '../../utils/config.dart';
import 'konsultasiState.dart';

class KonsultasiBloc extends Cubit<KonsultasiState> {
  KonsultasiBloc() : super(DataInitialState());
  static const String link = Configs.LINK;
  KonsultasiAPI konsultasiAPI = KonsultasiAPI();

  getDataHealthWorker({required String token}) async {
    List<User> healthWorker =
        await konsultasiAPI.getListHealthWorker(token: token);
    emit(HealthWorkerLoaded(healthWorker));
  }

  getLatestMesage({required String userID, required String token}) async {
    List<MessageModel> list =
        await konsultasiAPI.getListLatestMessage(userID: userID, token: token);
    emit(ListLatestMesasage(list));
  }

  getIndividualMessage(
      {required String senderID,
      required String receiverID,
      required String token}) async {
    List<MessageModel> list = await konsultasiAPI.getIndividualMessage(
        senderID: senderID, receiverID: receiverID, token: token);
    emit(ListIndividualMesasage(list));
  }
}
