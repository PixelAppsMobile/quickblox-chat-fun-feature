import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quickblox_polls_feature/presentation/navigation/navigation_service.dart';
import 'package:quickblox_polls_feature/presentation/screens/splash/splash_screen.dart';

import 'bloc/chat/chat_screen_bloc.dart';
import 'bloc/login/login_screen_bloc.dart';
import 'bloc/splash/bloc/splash_screen_bloc.dart';

Future<void> main() async {
  await Hive.initFlutter();
  runApp(const MyApp());
}

const String DEFAULT_USER_PASSWORD = "quickblox";

const String APPLICATION_ID = "98873";
const String AUTH_KEY = "XrRVVg6MTGwyDOz";
const String AUTH_SECRET = "wNuD9KZeW9JuqUB";
const String ACCOUNT_KEY = "J-GzyJLoeRt_hFQwdh_Z";

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xff3978fc),
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    return MultiProvider(
      providers: [
        Provider<SplashScreenBloc>.value(value: SplashScreenBloc()),
        Provider<LoginScreenBloc>.value(value: LoginScreenBloc()),
        // Provider<DialogsScreenBloc>.value(value: DialogsScreenBloc()),
        // Provider<AppInfoScreenBloc>.value(value: AppInfoScreenBloc()),
        // Provider<SelectUsersScreenBloc>.value(value: SelectUsersScreenBloc()),
        Provider<ChatScreenBloc>.value(value: ChatScreenBloc()),
        // Provider<DeliveredViewedScreenBloc>.value(
        //     value: DeliveredViewedScreenBloc()),
        // Provider<EnterChatNameScreenBloc>.value(
        //     value: EnterChatNameScreenBloc()),
        // Provider<ChatInfoScreenBloc>.value(value: ChatInfoScreenBloc())
      ],
      child: MaterialApp(
        title: 'Chat sample',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          accentColor: Colors.blue,
          textTheme:
              Theme.of(context).textTheme.apply(bodyColor: Colors.black87),
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
        ),
        navigatorKey: NavigationService().navigatorKey,
        home: const SplashScreen(),
      ),
    );
  }
}
