import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stunt_application/models/api_massage.dart';
import '../../pages/Login_Register/login_register_api.dart';
import '../../utils/SessionManager.dart';
import '../../utils/config.dart';
import 'login_state.dart';

class LoginBloc extends Cubit<LoginState> {
  LoginBloc() : super(LoginInitial());
  static const String link = Configs.LINK;

  Login_Register_Api api = Login_Register_Api();

  Future<API_Massage> login(
      {required String noHp, required String password}) async {
    API_Massage result = await api.login(noHp: noHp, password: password);
    final isLoggedIn = await SessionManager.isUserLoggedIn();
    final isSessionExpired = await SessionManager.isSessionExpired();
    emit(LoggedInState(isLoggedIn, isSessionExpired));
    return result;
  }

  isLogIn() async {
    final isLoggedIn = await SessionManager.isUserLoggedIn();
    final isSessionExpired = await SessionManager.isSessionExpired();
    emit(LoggedInState(isLoggedIn, isSessionExpired));
  }

  logout() async {
    await SessionManager.logout();
    final isLoggedIn = await SessionManager.isUserLoggedIn();
    final isSessionExpired = await SessionManager.isSessionExpired();
    emit(LoggedInState(isLoggedIn, isSessionExpired));
  }
}
