// ignore_for_file: non_constant_identifier_names

import 'package:equatable/equatable.dart';
import 'package:stunt_application/models/user.dart';

import '../../models/daftar_vaksin.dart';
import '../../models/data_anak_model.dart';
import '../../models/data_imt_5_18.dart';
import '../../models/data_tabel_status_gizi_model.dart';
import '../../models/jadwal_vaksin_model.dart';
import '../../models/kota_model.dart';
import '../../models/menu_makan_model.dart';
import '../../models/rekomendasiMenu.dart';

abstract class AllState extends Equatable {
  const AllState();

  @override
  List<Object> get props => [];
}

class DataInitialState extends AllState {}

class UserDataLoaded extends AllState {
  final User user;

  const UserDataLoaded(this.user);

  @override
  List<Object> get props => [user];
}

class DataAnakLoaded extends AllState {
  final List<DataAnakModel> dataAnak;

  const DataAnakLoaded(this.dataAnak);

  @override
  List<Object> get props => [dataAnak];
}

class DetailAnakLoaded extends AllState {
  final DataAnakModel detailAnak;

  const DetailAnakLoaded(this.detailAnak);

  @override
  List<Object> get props => [detailAnak];
}

class DataTabelStatusGiziLoaded extends AllState {
  final List<DataTabelStatusGizi> list_bb_umur;
  final List<DataTabelStatusGizi> list_tb_umur;
  final List<DataTabelStatusGizi> list_bb_pb;
  final List<DataTabelStatusGizi> list_bb_tb;
  final List<DataTabelStatusGizi> list_imt_umur;
  final List<DataIMT> list_imt_umur_518;

  const DataTabelStatusGiziLoaded(
      this.list_bb_umur,
      this.list_tb_umur,
      this.list_bb_pb,
      this.list_bb_tb,
      this.list_imt_umur,
      this.list_imt_umur_518);

  @override
  List<Object> get props => [
        list_bb_umur,
        list_tb_umur,
        list_bb_pb,
        list_bb_tb,
        list_imt_umur,
        list_imt_umur_518
      ];
}

class ListKotaLoaded extends AllState {
  final List<KotaModel> listKota;

  const ListKotaLoaded(this.listKota);

  @override
  List<Object> get props => [listKota];
}

class ListJadwalVaksinLoaded extends AllState {
  final List<JadwalVaksinModel> listJadwalVaksin;

  const ListJadwalVaksinLoaded(this.listJadwalVaksin);

  @override
  List<Object> get props => [listJadwalVaksin];
}

class DaftarVaksinLoaded extends AllState {
  final List<DaftarVaksinModel> daftar_vaksin;

  const DaftarVaksinLoaded(this.daftar_vaksin);

  @override
  List<Object> get props => [daftar_vaksin];
}

class MenuMakanLoaded extends AllState {
  final List<MenuMakanModel> menuMakan;

  const MenuMakanLoaded(this.menuMakan);

  @override
  List<Object> get props => [menuMakan];
}

class RekomendasiMenuLoaded extends AllState {
  final List<RekomendasiMenu> rekomendasiMenu;

  const RekomendasiMenuLoaded(this.rekomendasiMenu);

  @override
  List<Object> get props => [rekomendasiMenu];
}

class DataErrorState extends AllState {
  final String errorMessage;

  const DataErrorState(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
