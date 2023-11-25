// ignore_for_file: non_constant_identifier_names

import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:stunt_application/models/data_anak_model.dart';
import '../../models/api_massage.dart';
import '../../utils/config.dart';

class DataAnakApi {
  DataAnakApi();

  static const String link = Configs.LINK;
  final Dio dio = Dio();

  Future<List<DataAnakModel>> getDataAnak(
      {required String userID, required String token}) async {
    List<DataAnakModel> data = [];
    try {
      dio.options.headers['x-access-token'] = token;
      final response = await dio.get(
        '${link}get_data_anak',
        data: {'userID': userID},
      );
      if (response.data != null) {
        data = response.data != null
            ? (response.data as List)
                .map((userJson) => DataAnakModel.fromJson(userJson))
                .toList()
            : [];
      } else {
        data = [];
      }
      return data;
    } on DioException catch (error) {
      if (error.response != null) {
        log('Get Data Anak : ${error.response!.data['error']}');
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        log('Get Data Anak : ${error.requestOptions.toString()}');
        log('Get Data Anak : ${error.message.toString()}');
      }
      return data;
    }
  }

  Future<DataAnakModel> getDetailAnak(
      {required String userID,
      required String id_anak,
      required String token}) async {
    DataAnakModel data = DataAnakModel();
    try {
      dio.options.headers['x-access-token'] = token;
      final response = await dio.get(
        '${link}get_detail_anak',
        data: {'userID': userID, 'id_anak': id_anak},
      );
      if (response.data != null) {
        data = response.data != null
            ? DataAnakModel.fromJson(response.data)
            : DataAnakModel();
      } else {
        data = DataAnakModel();
      }
      return data;
    } on DioException catch (error) {
      if (error.response != null) {
        log('Get Data Anak : ${error.response!.data['error']}');
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        log('Get Data Anak : ${error.requestOptions.toString()}');
        log('Get Data Anak : ${error.message.toString()}');
      }
      return data;
    }
  }

  Future<API_Message> addDataAnak(
      {required String userID,
      required String namaAnak,
      required String jenisKelamin,
      required String tanggalLahir,
      required String beratbadan,
      required String tinggibadan,
      required String lingkarkepala,
      required String token}) async {
    try {
      dio.options.headers['x-access-token'] = token;
      final response = await dio.post(
        '${link}insert_data_anak',
        data: {
          'userID': userID,
          "nama_anak": namaAnak,
          "jenis_kelamin": jenisKelamin,
          "tanggal_lahir": tanggalLahir,
          "berat_badan": double.parse(beratbadan),
          "tinggi_badan": double.parse(tinggibadan),
          "lingkar_kepala": double.parse(lingkarkepala),
          "pengukuran_terakhir": DateFormat('yyyy-MM-dd').format(DateTime.now())
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

  Future<API_Message> updateDataAnak(
      {required String id_anak,
      required String userID,
      required String namaAnak,
      required String jenisKelamin,
      required String tanggalLahir,
      required String beratbadan,
      required String tinggibadan,
      required String lingkarkepala,
      required String token}) async {
    try {
      dio.options.headers['x-access-token'] = token;
      final response = await dio.post(
        '${link}update_data_anak',
        data: {
          'id_anak': id_anak,
          'userID': userID,
          "nama_anak": namaAnak,
          "jenis_kelamin": jenisKelamin,
          "tanggal_lahir": tanggalLahir,
          "berat_badan": double.parse(beratbadan),
          "tinggi_badan": double.parse(tinggibadan),
          "lingkar_kepala": double.parse(lingkarkepala),
          "pengukuran_terakhir": DateFormat('yyyy-MM-dd').format(DateTime.now())
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
}
