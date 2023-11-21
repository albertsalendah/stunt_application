import 'dart:developer';

import 'package:dio/dio.dart';
import '../../models/data_imt_5_18.dart';
import '../../models/data_tabel_status_gizi_model.dart';
import '../../utils/config.dart';

class DataPertumbuhanAPI {
  DataPertumbuhanAPI();

  static const String link = Configs.LINK;
  final Dio dio = Dio();

  Future<List<DataTabelStatusGizi>> getBeratBadanUmur(
      {required String jenisKelamin, required String token}) async {
    List<DataTabelStatusGizi> data = [];
    try {
      dio.options.headers['x-access-token'] = token;
      final response = await dio.get(
        jenisKelamin == 'Laki-Laki'
            ? '${link}get_berat_badan_umur_laki_laki'
            : '${link}get_berat_badan_umur_perempuan',
      );
      if (response.data != null) {
        data = (response.data as List)
            .map((userJson) => DataTabelStatusGizi.fromJson(userJson))
            .toList();
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

  Future<List<DataTabelStatusGizi>> getTinggiBadanUmur(
      {required String jenisKelamin, required String token}) async {
    List<DataTabelStatusGizi> data = [];
    try {
      dio.options.headers['x-access-token'] = token;
      final response = await dio.get(
        jenisKelamin == 'Laki-Laki'
            ? '${link}get_tinggi_badan_umur_laki_laki'
            : '${link}get_tinggi_badan_umur_perempuan',
      );
      if (response.data != null) {
        data = (response.data as List)
            .map((userJson) => DataTabelStatusGizi.fromJson(userJson))
            .toList();
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

  Future<List<DataTabelStatusGizi>> getBeratBadanPanjangBadan(
      {required String jenisKelamin, required String token}) async {
    List<DataTabelStatusGizi> data = [];
    try {
      dio.options.headers['x-access-token'] = token;
      final response = await dio.get(
        jenisKelamin == 'Laki-Laki'
            ? '${link}get_berat_badan_panjang_badan_laki_laki'
            : '${link}get_berat_badan_panjang_badan_perempuan',
      );
      if (response.data != null) {
        data = (response.data as List)
            .map((userJson) => DataTabelStatusGizi.fromJson(userJson))
            .toList();
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

  Future<List<DataTabelStatusGizi>> getBeratBadanTinggiBadan(
      {required String jenisKelamin, required String token}) async {
    List<DataTabelStatusGizi> data = [];
    try {
      dio.options.headers['x-access-token'] = token;
      final response = await dio.get(
        jenisKelamin == 'Laki-Laki'
            ? '${link}get_berat_badan_tinggi_badan_laki_laki'
            : '${link}get_berat_badan_tinggi_badan_perempuan',
      );
      if (response.data != null) {
        data = (response.data as List)
            .map((userJson) => DataTabelStatusGizi.fromJson(userJson))
            .toList();
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

  Future<List<DataTabelStatusGizi>> getImtUmur(
      {required String jenisKelamin, required String token}) async {
    List<DataTabelStatusGizi> data = [];
    try {
      dio.options.headers['x-access-token'] = token;
      final response = await dio.get(
        jenisKelamin == 'Laki-Laki'
            ? '${link}get_imt_umur_laki_laki'
            : '${link}get_imt_umur_perempuan',
      );
      if (response.data != null) {
        data = (response.data as List)
            .map((userJson) => DataTabelStatusGizi.fromJson(userJson))
            .toList();
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

  Future<List<DataIMT>> getImtUmur518(
      {required String jenisKelamin, required String token}) async {
    List<DataIMT> data = [];
    try {
      dio.options.headers['x-access-token'] = token;
      final response = await dio.get(
        jenisKelamin == 'Laki-Laki'
            ? '${link}get_imt_umur_5_18_laki_laki'
            : '${link}get_imt_umur_5_18_perempuan',
      );
      if (response.data != null) {
        data = (response.data as List)
            .map((userJson) => DataIMT.fromJson(userJson))
            .toList();
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
}
