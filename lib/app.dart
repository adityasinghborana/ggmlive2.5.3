import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:country_code_picker/country_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:spagreen/src/localizations.dart';
import 'config.dart';
import 'src/models/get_config_model.dart';
import 'src/screen/main_screen.dart';
import 'src/screen/onboard_screen.dart';
import 'src/services/get_config_service.dart';
import 'src/widgets/interner_issue_dialog.dart';
import 'src/widgets/internet_connectivity.dart';
import 'constants.dart';
import 'src/bloc/auth/registration_bloc.dart';
import 'src/bloc/firebase_auth/firebase_auth_bloc.dart';
import 'src/bloc/phone_auth/phone_auth_bloc.dart';
import 'src/screen/login_screen.dart';
import 'src/server/repository.dart';
import 'src/services/authentication_service.dart';
import 'src/utils/route.dart';
import 'src/utils/localization_helper.dart' as helper;
import 'src/bloc/auth/login_bloc.dart';
import 'src/server/phone_auth_repository.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MyApp extends StatefulWidget {
  static void setLocal(BuildContext context, Locale locale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(locale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with AfterLayoutMixin {
  GetConfigModel? getConfigModel;
  bool isFirstSeen = false;
  String? notifyContent;

  Locale? _locale;
  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    helper.getLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  void initState() {
    printLog("_MyAppState initState");
    Future.delayed(
      Duration(seconds: 1),
      () {
        MyConnectivity.instance.initialise();
        MyConnectivity.instance.myStream.listen((onData) {
          printLog("[_MyAppState] internet issue change: $onData");

          if (MyConnectivity.instance.isIssue(onData)) {
            if (MyConnectivity.instance.isShow == false) {
              MyConnectivity.instance.isShow = true;
              showDialogNotInternet(context).then((onValue) {
                MyConnectivity.instance.isShow = false;
                printLog("[showDialogNotInternet] dialog closed $onValue");
              });
            }
          } else {
            if (MyConnectivity.instance.isShow == true) {
              Navigator.of(context).pop();
              MyConnectivity.instance.isShow = false;
            }
          }
        });
      },
    );

    configOneSignal();
    super.initState();
  }

  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    printLog("[_MyAppState] afterFirstLayout");
    isFirstSeen = await (checkFirstSeen() as FutureOr<bool>);
    setState(() {});
  }

  Future checkFirstSeen() async {
    var box = Hive.box('seenBox');
    bool _seen = await box.get("isFirstSeen") ?? false;
    if (_seen) {
      return false;
    } else {
      await box.put("isFirstSeen", true);
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    printLog("MyAppState");
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (context) => AuthService(),
        ),
        Provider<GetConfigService>(
          create: (context) => GetConfigService(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => LoginBloc(Repository())),
          BlocProvider(create: (context) => RegistrationBloc(Repository())),
          BlocProvider(create: (context) => FirebaseAuthBloc(Repository())),
          BlocProvider(
              create: (context) =>
                  PhoneAuthBloc(userRepository: UserRepository())),
        ],
        child: MaterialApp(
          title: "Meet Air",
          debugShowCheckedModeBanner: false,
          routes: Routes.getRoute(),
          supportedLocales: Config.supportedLanguageList,
          locale: _locale,
          localizationsDelegates: [
            MyLocalization.delegate,
            CountryLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (deviceLocale, supportedLocales) {
            for (var locale in supportedLocales) {
              if (locale.languageCode == deviceLocale!.languageCode &&
                  locale.countryCode == deviceLocale.countryCode) {
                return deviceLocale;
              }
            }
            return supportedLocales.first;
          },
          home: RenderFirstScreen(
            isFirstSeen: isFirstSeen,
          ),
        ),
      ),
    );
  }

  void configOneSignal() async {
    //if (!mounted) return;
    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    OneSignal.shared.setRequiresUserPrivacyConsent(
        await OneSignal.shared.userProvidedPrivacyConsent());
    OneSignal.shared.setNotificationWillShowInForegroundHandler((event) {
      event.complete(event.notification);
    });
    OneSignal.shared.promptUserForPushNotificationPermission();
    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {});
    OneSignal.shared
        .setPermissionObserver((OSPermissionStateChanges changes) {});
    OneSignal.shared
        .setInAppMessageClickedHandler((OSInAppMessageAction action) {});
    await OneSignal.shared.setAppId(Config.oneSignalAppID);
  }
}

// ignore: must_be_immutable
class RenderFirstScreen extends StatelessWidget {
  bool? isMandatoryLogin = false;
  final bool? isFirstSeen;

  RenderFirstScreen({Key? key, this.isFirstSeen}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    printLog("RenderFirstScreen");
    return ValueListenableBuilder(
      valueListenable: Hive.box<GetConfigModel?>('getConfigbox').listenable(),
      builder: (context, dynamic box, widget) {
        isMandatoryLogin = box.get(0).appConfig.mandatoryLogin;
        //isMandatoryLogin = true;
        return renderFirstScreen(isMandatoryLogin);
      },
    );
  }

  Widget renderFirstScreen(bool? isMandatoryLogin) {
    print(isMandatoryLogin);
    if (isFirstSeen!) {
      return OnBoardScreen(
        isMandatoryLogin: isMandatoryLogin,
      );
    } else if (isMandatoryLogin!) {
      return LoginPage();
    } else {
      return MainScreen();
    }
  }
}
