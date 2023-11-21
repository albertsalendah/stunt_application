// ignore_for_file: non_constant_identifier_names

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stunt_application/models/daftar_vaksin.dart';
import 'package:stunt_application/models/user.dart';
import 'package:stunt_application/pages/Imunisasi/imunisasi_api.dart';

import '../../models/data_anak_model.dart';
import '../../models/data_imt_5_18.dart';
import '../../models/data_tabel_status_gizi_model.dart';
import '../../models/jadwal_vaksin_model.dart';
import '../../models/kota_model.dart';
import '../../models/menu_makan_model.dart';
import '../../models/rekomendasiMenu.dart';
import '../../pages/Akun/edit_akun_api.dart';
import '../../pages/Data_Anak/data_anak_api.dart';
import '../../pages/Data_Pertumbuhan/data_pertumbuhan_api.dart';
import '../../pages/Menajemen_Gizi/menajemin_gizi_api.dart';
import '../../utils/config.dart';
import 'all_state.dart';

class AllBloc extends Cubit<AllState> {
  AllBloc() : super(DataInitialState());
  static const String link = Configs.LINK;

  EditAkunApi akunAPI = EditAkunApi();
  DataAnakApi dataanakapi = DataAnakApi();
  DataPertumbuhanAPI dataPertumbuhanAPI = DataPertumbuhanAPI();
  ImunisasiAPI imunisasiAPI = ImunisasiAPI();
  MenajemenGiziApi menuMaknApi = MenajemenGiziApi();

  getUserData({required String userID, required String token}) async {
    User user = await akunAPI.getDataUser(userID: userID, token: token);
    emit(UserDataLoaded(user));
  }

  getDataAnak({required User user, required String token}) async {
    List<DataAnakModel> dataAnak =
        await dataanakapi.getDataAnak(userID: user.userID ?? '', token: token);
    emit(DataAnakLoaded(dataAnak));
  }

  getDetailDataAnak(
      {required User user,
      required String id_anak,
      required String token}) async {
    DataAnakModel dataAnak = await dataanakapi.getDetailAnak(
        userID: user.userID ?? '', id_anak: id_anak, token: token);
    emit(DetailAnakLoaded(dataAnak));
  }

  getDataTabelStatusGizi(
      {required String jenisKelamin, required String token}) async {
    List<DataTabelStatusGizi> listBbUmur = await dataPertumbuhanAPI
        .getBeratBadanUmur(jenisKelamin: jenisKelamin, token: token);
    List<DataTabelStatusGizi> listTbUmur = await dataPertumbuhanAPI
        .getTinggiBadanUmur(jenisKelamin: jenisKelamin, token: token);
    List<DataTabelStatusGizi> listBbPb = await dataPertumbuhanAPI
        .getBeratBadanPanjangBadan(jenisKelamin: jenisKelamin, token: token);
    List<DataTabelStatusGizi> listBbTb = await dataPertumbuhanAPI
        .getBeratBadanTinggiBadan(jenisKelamin: jenisKelamin, token: token);
    List<DataTabelStatusGizi> listImtUmur = await dataPertumbuhanAPI.getImtUmur(
        jenisKelamin: jenisKelamin, token: token);
    List<DataIMT> listImtUmur518 = await dataPertumbuhanAPI.getImtUmur518(
        jenisKelamin: jenisKelamin, token: token);
    emit(DataTabelStatusGiziLoaded(listBbUmur, listTbUmur, listBbPb, listBbTb,
        listImtUmur, listImtUmur518));
  }

  getListKota({required String token}) async {
    List<KotaModel> list = await imunisasiAPI.daftarKota(token: token);
    emit(ListKotaLoaded(list));
  }

  getListJadwalVaksin(
      {required String userID,
      required String id_anak,
      required String token}) async {
    List<JadwalVaksinModel> list = await imunisasiAPI.listJadwalVaksin(
        userID: userID, id_anak: id_anak, token: token);
    emit(ListJadwalVaksinLoaded(list));
  }

  getDaftarVaksin({required int umur, required String token}) async {
    List<DaftarVaksinModel> list =
        await imunisasiAPI.daftarVaksin(umur: umur, token: token);
    emit(DaftarVaksinLoaded(list));
  }

  getMenuMakan(
      {required String userID,
      required String id_anak,
      required String tanggal,
      required String token}) async {
    List<MenuMakanModel> menuMakan = await menuMaknApi.getListMenuMakan(
        userID: userID, id_anak: id_anak, tanggal: tanggal, token: token);
    emit(MenuMakanLoaded(menuMakan));
  }

  getRekomendasiMenu({required String token}) async {
    List<RekomendasiMenu> menuMakan =
        await menuMaknApi.getRekomendasiMenu(token: token);
    emit(RekomendasiMenuLoaded(menuMakan));
  }
}
