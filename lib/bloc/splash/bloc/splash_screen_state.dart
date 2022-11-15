abstract class SplashScreenStates {}

class AuthenticationErrorState extends SplashScreenStates {
  final String error;

  AuthenticationErrorState(this.error);
}

class NeedLoginState extends SplashScreenStates {}

class LoginSuccessState extends SplashScreenStates {}

class LoginInProgressState extends SplashScreenStates {}
