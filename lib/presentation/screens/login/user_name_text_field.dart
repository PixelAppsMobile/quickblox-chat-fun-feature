import 'package:flutter/material.dart';

import '../../../bloc/login/login_screen_bloc.dart';
import '../../../bloc/login/login_screen_events.dart';

class UserNameTextField extends StatelessWidget {
  UserNameTextField({Key? key, this.textField, this.loginBloc})
      : super(key: key);

  final TextField? textField;
  final LoginScreenBloc? loginBloc;
  final TextEditingController txtController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(255, 217, 229, 255),
            offset: Offset(0, 6),
            blurRadius: 11.0,
          )
        ],
      ),
      child: TextField(
        controller: txtController,
        onChanged: (userName) {
          if (userName.contains('  ')) {
            userName = userName.replaceAll('  ', ' ');
            txtController
              ..text = userName
              ..selection = TextSelection.collapsed(offset: userName.length);
          } else {
            loginBloc?.events?.add(ChangedUsernameFieldEvent(userName));
          }
        },
        style: const TextStyle(fontSize: 17.0),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(10),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
