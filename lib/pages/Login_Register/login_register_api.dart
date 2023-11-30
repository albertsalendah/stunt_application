// ignore_for_file: camel_case_types, non_constant_identifier_names
import 'dart:developer';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:stunt_application/models/user.dart';

import '../../models/api_massage.dart';
import '../../utils/SessionManager.dart';
import '../../utils/config.dart';
import '../../utils/firebase_api.dart';

class Login_Register_Api {
  Login_Register_Api();
  static const String link = Configs.LINK;
  final Dio dio = Dio();

  Future<API_Message> login({
    required String noHp,
    required String password,
  }) async {
    try {
      final response = await dio.post('${link}login',
          data: {'no_hp': noHp, 'password': password, 'health_worker': false});
      dynamic token = response.data['token'];
      User user = User.fromJson(response.data['user']);
      String? fcm_token = await FirebaseApi().getTokenFCM();
      if (fcm_token != null) {
        if (user.fcm_token != fcm_token) {
          updateTokenFCM(userID: user.userID ?? '', fcm_token: fcm_token);
          log('Updated Token');
        }
      }
      await SessionManager.saveToken(token);
      await SessionManager.saveUser(user);
      return API_Message(status: true, message: '');
    } on DioException catch (error) {
      if (error.response != null) {
        String err = error.response!.data!['error'].toString();
        log(err);
      } else {
        // Handle other Dio errors (e.g., network error)
        log('DioError: ${error.message}');
      }
      return API_Message(
          status: false, message: error.response?.data?['error'].toString());
    }
  }

  Future<API_Message> registerUser(
      {required String nama,
      required String noHp,
      required String email,
      required String password,
      String? fcm_token,
      Uint8List? foto}) async {
    try {
      FormData formData = FormData.fromMap({
        'nama': nama,
        'no_hp': noHp,
        'email': email,
        'password': password,
        'fcm_token': fcm_token,
        'keterangan': '',
        'health_worker': false,
        'foto': foto != null
            ? MultipartFile.fromBytes(foto, filename: '$nama.jpg')
            : null,
      });
      final response = await dio.post(
        '${link}register',
        data: formData,
      );
      return API_Message(status: true, message: response.data['message']);
    } on DioException catch (error) {
      log('Error registering user: $error');
      return API_Message(status: false, message: error.response!.data['error']);
    }
  }

  Future<API_Message> updateTokenFCM(
      {required String userID, required String fcm_token}) async {
    try {
      final response = await dio.post(
        '${link}update_token_fcm',
        data: {
          'userID': userID,
          "fcm_token": fcm_token,
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
