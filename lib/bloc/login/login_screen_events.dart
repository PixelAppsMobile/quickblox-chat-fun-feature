

abstract class LoginScreenEvents {}

class LoginPressedEvent extends LoginScreenEvents {}

class ChangedLoginFieldEvent extends LoginScreenEvents {
  final String login;

  ChangedLoginFieldEvent(this.login);
}

class ChangedUsernameFieldEvent extends LoginScreenEvents {
  final String userName;

  ChangedUsernameFieldEvent(this.userName);
}
