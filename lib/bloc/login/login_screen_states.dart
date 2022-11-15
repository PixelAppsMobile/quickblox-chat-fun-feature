import 'package:quickblox_sdk/models/qb_user.dart';


abstract class LoginScreenStates {}

class LoginSuccessState extends LoginScreenStates {
  final QBUser user;

  LoginSuccessState(this.user);
}

class LoginInProgressState extends LoginScreenStates {}

class LoginErrorState extends LoginScreenStates {
  final String error;

  LoginErrorState(this.error);
}

class UserNameFieldValidState extends LoginScreenStates {}

class UserNameFieldInvalidState extends LoginScreenStates {}

class LoginFieldInvalidState extends LoginScreenStates {}

class LoginFieldValidState extends LoginScreenStates {}

class AllowLoginState extends LoginScreenStates {}
