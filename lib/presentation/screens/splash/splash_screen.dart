import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quickblox_polls_feature/presentation/screens/chat/chat_screen.dart';
import 'package:quickblox_polls_feature/presentation/screens/login/login_screen.dart';

import '../../../bloc/splash/bloc/splash_screen_bloc.dart';
import '../../../bloc/splash/bloc/splash_screen_event.dart';
import '../../../bloc/splash/bloc/splash_screen_state.dart';
import '../../../stream_builder_with_listener.dart';
import '../../../utils/notification_utils.dart';
import '../../navigation/navigation_service.dart';
import '../base_screen_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends BaseScreenState<SplashScreenBloc> {
  @override
  Widget build(BuildContext context) {
    initBloc(context);
    bloc?.events?.add(AuthEvent());

    return Scaffold(
      body: Container(
        color: const Color(0xff3978fc),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Center(child: SvgPicture.asset('assets/icons/qb-logo.svg')),
            StreamBuilderWithListener<SplashScreenStates>(
              listener: (state) {
                if (state is NeedLoginState) {
                  NavigationService().pushReplacement(const LoginScreen());
                }
                if (state is LoginSuccessState) {
                  NavigationService().pushReplacement(
                    const ChatScreen(),
                  );
                }
                if (state is AuthenticationErrorState) {
                  NotificationBarUtils.showSnackBarError(context, state.error,
                      errorCallback: () {
                    bloc?.events?.add(AuthEvent());
                  });
                }
              },
              stream: bloc?.states?.stream as Stream<SplashScreenStates>,
              builder: (context, state) {
                if (state.data is LoginInProgressState) {
                  return Container(
                    alignment: Alignment.bottomCenter,
                    child: const Padding(
                      padding: EdgeInsets.only(bottom: 150),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                        strokeWidth: 4.0,
                      ),
                    ),
                  );
                }
                return const Text("");
              },
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: const Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Text(
                  'Flutter Chat Sample',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
