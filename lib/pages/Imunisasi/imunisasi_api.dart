import 'dart:developer';

import 'package:dio/dio.dart';

import '../../models/api_massage.dart';
import '../../models/daftar_vaksin.dart';
import '../../models/jadwal_vaksin_model.dart';
import '../../models/kota_model.dart';
import '../../utils/config.dart';

class ImunisasiAPI {
  ImunisasiAPI();

  static const String link = Configs.LINK;
  final Dio dio = Dio();

  Future<List<JadwalVaksinModel>> listJadwalVaksin(
      {required String userID,
      required String id_anak,
      required String token}) async {
    List<JadwalVaksinModel> data = [];
    try {
      dio.options.headers['x-access-token'] = token;
      final response = await dio.post(
        '${link}jadwalvaksin',
        data: {'userID': userID, "id_anak": id_anak},
      );
      data = response.data != null
          ? (response.data as List)
              .map((userJson) => JadwalVaksinModel.fromJson(userJson))
              .toList()
          : [];
      return data;
    } on DioException catch (error) {
      if (error.response != null) {
        log('List Kota : ${error.response!.data['error']}');
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        log('List Kota : ${error.requestOptions.toString()}');
        log('List Kota : ${error.message.toString()}');
      }
      return data;
    }
  }

  Future<List<DaftarVaksinModel>> daftarVaksin(
      {required int umur, required String token}) async {
    List<DaftarVaksinModel> data = [];
    try {
      dio.options.headers['x-access-token'] = token;
      final response = await dio.post(
        '${link}daftarvaksin',
        data: {'umur': umur},
      );
      data = response.data != null
          ? (response.data as List)
              .map((userJson) => DaftarVaksinModel.fromJson(userJson))
              .toList()
          : [];
      return data;
    } on DioException catch (error) {
      if (error.response != null) {
        log('List Kota : ${error.response!.data['error']}');
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        log('List Kota : ${error.requestOptions.toString()}');
        log('List Kota : ${error.message.toString()}');
      }
      return data;
    }
  }

  Future<API_Message> tambahJadwalVaksin(
      {required String id_anak,
      required String userID,
      required String lokasi,
      required String tanggal_vaksin,
      required String tipe_vaksin,
      required String token}) async {
    try {
      dio.options.headers['x-access-token'] = token;
      final response = await dio.post(
        '${link}tambah_jadwal_vaksin',
        data: {
          'id_anak': id_anak,
          'userID': userID,
          "lokasi": lokasi,
          "tanggal_vaksin": tanggal_vaksin,
          "tipe_vaksin": tipe_vaksin
        },
      );
      return API_Message(status: true, message: response.data['message']);
    } on DioException catch (error) {
      if (error.response != null) {
        log(error.response!.data['error']);
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        log(error.requestOptions.toString());
        log(error.message.toString());
      }
      return API_Message(status: false, message: error.message.toString());
    }
  }

  Future<List<KotaModel>> daftarKota({required String token}) async {
    List<KotaModel> data = [];
    try {
      dio.options.headers['x-access-token'] = token;
      final response = await dio.get('${link}listkota');
      data = response.data != null
          ? (response.data as List)
              .map((userJson) => KotaModel.fromJson(userJson))
              .toList()
          : [];
      return data;
    } on DioException catch (error) {
      if (error.response != null) {
        log('List Kota : ${error.response!.data['error']}');
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        log('List Kota : ${error.requestOptions.toString()}');
        log('List Kota : ${error.message.toString()}');
      }
      return data;
    }
  }
}
