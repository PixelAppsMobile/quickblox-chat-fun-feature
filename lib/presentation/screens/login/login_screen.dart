import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:quickblox_polls_feature/presentation/screens/chat/chat_screen.dart';
import 'package:quickblox_polls_feature/presentation/screens/login/user_name_text_field.dart';

import '../../../bloc/login/login_screen_bloc.dart';
import '../../../bloc/login/login_screen_events.dart';
import '../../../bloc/login/login_screen_states.dart';
import '../../../stream_builder_with_listener.dart';
import '../../../utils/notification_utils.dart';
import '../../navigation/navigation_service.dart';
import '../../widgets/decorated_app_bar.dart';
import '../../widgets/progress.dart';
import '../base_screen_state.dart';
import 'login_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends BaseScreenState<LoginScreenBloc> {
  LoginTextField? _loginTextField;
  UserNameTextField? _userNameTextField;

  @override
  Widget build(BuildContext context) {
    initBloc(context);

    _loginTextField = LoginTextField(loginBloc: bloc as LoginScreenBloc);
    _userNameTextField = UserNameTextField(loginBloc: bloc as LoginScreenBloc);

    return Scaffold(
      appBar: DecoratedAppBar(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Enter to chat'),
          backgroundColor: const Color(0xff3978fc),
          leading: Container(),
          // actions: <Widget>[
          // IconButton(
          //     icon: SvgPicture.asset('assets/icons/info.svg'),
          //     onPressed: () {
          //       NavigationService().push(AppInfoScreenRoute);
          //     })
          // ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(left: 16, right: 16),
        children: [
          Container(
            padding: const EdgeInsets.only(top: 28),
            child: const Text(
              'Please enter your login \n and display name',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17),
            ),
          ),
          Container(
              padding: const EdgeInsets.only(top: 28),
              child: const Text('Login',
                  style: TextStyle(color: Color(0x85333333), fontSize: 13))),
          Container(
            padding: const EdgeInsets.only(top: 11),
            child: _loginTextField,
          ),
          StreamProvider<LoginScreenStates>(
              create: (context) =>
                  bloc?.states?.stream as Stream<LoginScreenStates>,
              initialData: LoginFieldValidState(),
              child: Selector<LoginScreenStates, LoginScreenStates>(
                selector: (_, state) => state,
                shouldRebuild: (previous, next) {
                  return next is LoginFieldInvalidState ||
                      next is LoginFieldValidState ||
                      next is AllowLoginState;
                },
                builder: (_, state, __) {
                  if (state is LoginFieldInvalidState) {
                    return Container(
                        padding: const EdgeInsets.only(top: 11),
                        child: const Text(
                            "Use your email or alphanumeric characters in a range from 3 to 50. First character must be a letter.",
                            style: TextStyle(
                                color: Color.fromRGBO(153, 169, 198, 1.0))));
                  }
                  return const Text("");
                },
              )),
          Container(
              padding: const EdgeInsets.only(top: 16),
              child: const Text('Username',
                  style: TextStyle(color: Color(0x85333333), fontSize: 13))),
          Container(
            padding: const EdgeInsets.only(top: 11),
            child: _userNameTextField,
          ),
          StreamProvider<LoginScreenStates>(
              create: (context) =>
                  bloc?.states?.stream as Stream<LoginScreenStates>,
              initialData: UserNameFieldValidState(),
              child: Selector<LoginScreenStates, LoginScreenStates>(
                  selector: (_, state) => state,
                  shouldRebuild: (previous, next) {
                    return next is UserNameFieldInvalidState ||
                        next is UserNameFieldValidState ||
                        next is AllowLoginState;
                  },
                  builder: (_, state, __) {
                    if (state is UserNameFieldInvalidState) {
                      return Container(
                          padding: const EdgeInsets.only(top: 11),
                          child: const Text(
                              "Use alphanumeric characters and spaces in a range from 3 to 20. Cannot contain more than one space in a row.",
                              style: TextStyle(
                                  color: Color.fromRGBO(153, 169, 198, 1.0))));
                    }
                    return const Text("");
                  })),
          Container(
              padding: const EdgeInsets.only(top: 42, left: 64, right: 64),
              child: StreamBuilderWithListener<LoginScreenStates>(
                stream: bloc?.states?.stream as Stream<LoginScreenStates>,
                listener: (state) {
                  if (state is LoginSuccessState) {
                    NavigationService().pushReplacement(const ChatScreen());
                  }
                  if (state is LoginErrorState) {
                    NotificationBarUtils.showSnackBarError(
                        this.context, state.error);
                  }
                },
                builder: (context, state) {
                  if (state.data is LoginInProgressState) {
                    return const Progress(Alignment.center);
                  }
                  return TextButton(
                      onPressed: state.data is AllowLoginState ||
                              state.data is LoginErrorState
                          ? () {
                              bloc?.events?.add(LoginPressedEvent());
                              FocusScope.of(context).unfocus();
                            }
                          : null,
                      style: ButtonStyle(
                          elevation: MaterialStateProperty.resolveWith(
                              (states) => states.contains(MaterialState.disabled)
                                  ? null
                                  : 3),
                          shadowColor: MaterialStateProperty.resolveWith(
                              (states) => states.contains(MaterialState.disabled)
                                  ? const Color(0xff99A9C6)
                                  : const Color(0x403978FC)),
                          backgroundColor: MaterialStateProperty.resolveWith(
                              (states) =>
                                  states.contains(MaterialState.disabled)
                                      ? const Color(0xff99A9C6)
                                      : const Color(0xff3978FC))),
                      child: Container(
                        padding: const EdgeInsets.only(top: 12, bottom: 12),
                        child: const Text(
                          'Login',
                          style: TextStyle(fontSize: 17, color: Colors.white),
                        ),
                      ));
                },
              ))
        ],
      ),
    );
  }
}
