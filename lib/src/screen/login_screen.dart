import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:spagreen/src/bloc/auth/login_bloc.dart';
import 'package:spagreen/src/bloc/auth/login_event.dart';
import 'package:spagreen/src/bloc/auth/login_state.dart';
import 'package:spagreen/src/bloc/firebase_auth/firebase_auth_bloc.dart';
import 'package:spagreen/src/bloc/firebase_auth/firebase_auth_event.dart';
import 'package:spagreen/src/bloc/firebase_auth/firebase_auth_state.dart';
import 'package:spagreen/src/models/get_config_model.dart';
import 'package:spagreen/src/models/password_reset_model.dart';
import 'package:spagreen/src/models/user_model.dart';
import 'package:spagreen/src/screen/phon_auth_screen.dart';
import 'package:spagreen/src/screen/sign_up_screen.dart';
import 'package:spagreen/src/services/get_config_service.dart';
import 'package:spagreen/src/utils/app_tags.dart';
import '../utils/localization_helper.dart' as helper;
import 'package:spagreen/src/server/repository.dart';
import 'package:spagreen/src/services/authentication_service.dart';
import 'package:spagreen/src/style/theme.dart';
import 'package:spagreen/src/utils/edit_text_utils.dart';
import 'package:spagreen/src/utils/loadingIndicator.dart';
import 'package:spagreen/src/utils/validators.dart';
import 'package:spagreen/src/widgets/google_fb_phone_btn.dart';
import 'package:spagreen/src/widgets/signup_submit_btn.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../config.dart';
import '../button_widget.dart';
import 'main_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();
//FacebookLogin facebookSignIn = new FacebookLogin();

class LoginPage extends StatefulWidget {
  static final String route = '/LoginScreen';
  LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final resetPassFormKey = GlobalKey<FormState>();
  PasswordResetModel? passwordResetModel;
  TextEditingController loginEmailController = new TextEditingController();
  TextEditingController loginPasswordController = new TextEditingController();
  TextEditingController resetPassEmailController = new TextEditingController();
  late bool _isLogged;
  late AppConfig? appConfig;
  late Bloc bloc;
  late Bloc firebaseAuthBloc;
  bool? isMandatoryLogin = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<LoginBloc>(context);
    firebaseAuthBloc = BlocProvider.of<FirebaseAuthBloc>(context);
    _isLogged = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final configService = Provider.of<GetConfigService>(context);
    _isLogged = authService.getUser() != null ? true : false;
    appConfig = configService.appConfig();
    isMandatoryLogin = appConfig != null ? appConfig!.mandatoryLogin : false;

    return new Scaffold(
      key: _scaffoldKey,
      body: _isLogged ? MainScreen() : _renderLoginWidget(authService),
    );
  }

  Widget _renderLoginWidget(authService) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginCompletingStateCompleted) {
          isLoading = false;
          AuthUser? user = state.getUser;
          if (user == null) {
            /*print('user is null');*/
            bloc.add(LoginCompletingFailed());
          } else {
            authService.updateUser(user);
          }
          if (authService.getUser() != null) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => MainScreen()),
                (Route<dynamic> route) => false);
          }
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return SingleChildScrollView(
              child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  //app logo bg
                  Container(
                    height: MediaQuery.of(context).size.height / 2.2,
                    decoration: BoxDecoration(
                      gradient: new LinearGradient(
                          colors: [
                            CustomTheme.primaryColor,
                            CustomTheme.primaryColorDark
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomRight,
                          stops: [0.0, 1.0],
                          tileMode: TileMode.clamp),
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 75.0),
                        child: Image.asset(
                          'assets/images/common/logo.png',
                          width: 74,
                          height: 68,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 60.0),
                        child: Column(
                          children: <Widget>[
                            Stack(
                              alignment: Alignment.bottomCenter,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(bottom: 30.0),
                                  decoration: new BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    boxShadow: CustomTheme.boxShadow,
                                    color: Colors.white,
                                  ),
                                  width: 300.0,
                                  height: 340,
                                  child: Column(
                                    children: <Widget>[
                                      SizedBox(height: 20.0),
                                      Text(
                                        helper.getTranslated(
                                            context, AppTags.login)!,
                                        style:
                                            CustomTheme.displayTextBoldColoured,
                                      ),
                                      Container(
                                        width: 60,
                                        height: 2,
                                        color: CustomTheme.primaryColor,
                                      ),
                                      SizedBox(height: 15.0),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0,
                                        ),
                                        child: Form(
                                          key: _formKey,
                                          child: Column(
                                            children: <Widget>[
                                              EditTextUtils()
                                                  .getCustomEditTextField(
                                                      hintValue:
                                                          helper.getTranslated(
                                                              context,
                                                              AppTags
                                                                  .emailAddress),
                                                      keyboardType:
                                                          TextInputType
                                                              .emailAddress,
                                                      controller:
                                                          loginEmailController,
                                                      prefixWidget: Image.asset(
                                                        'assets/images/common/email.png',
                                                        scale: 2.5,
                                                        height: 45.0,
                                                        width: 45.0,
                                                      ),
                                                      style: CustomTheme
                                                          .textFieldTitle,
                                                      validator: (value) {
                                                        return validateEmail(
                                                            value);
                                                      }),
                                              SizedBox(height: 20),
                                              EditTextUtils()
                                                  .getCustomEditTextField(
                                                      hintValue:
                                                          helper.getTranslated(
                                                              context,
                                                              AppTags.password),
                                                      keyboardType:
                                                          TextInputType.text,
                                                      controller:
                                                          loginPasswordController,
                                                      prefixWidget: Image.asset(
                                                        'assets/images/authImage/password.png',
                                                        scale: 2.5,
                                                        height: 45.0,
                                                        width: 45.0,
                                                      ),
                                                      style: CustomTheme
                                                          .textFieldTitle,
                                                      obscureValue: true,
                                                      validator: (value) {
                                                        return validateMinLength(
                                                            value);
                                                      }),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            helper.getTranslated(context,
                                                AppTags.forgetPassword)!,
                                            style: CustomTheme.smallTextStyle,
                                          ),
                                          _renderResetPassword(),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          !isMandatoryLogin!
                                              ? Row(
                                                  children: <Widget>[
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 8.0),
                                                        child: Text(
                                                          helper.getTranslated(
                                                              context,
                                                              AppTags
                                                                  .backText)!,
                                                          style: CustomTheme
                                                              .smallTextStyleColored,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Container(
                                                        height: 12.0,
                                                        width: 1.0,
                                                        color: CustomTheme
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : Container(),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                  context, SignUpScreen.route);
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: Text(
                                                helper.getTranslated(context,
                                                    AppTags.createNewAccount)!,
                                                style: CustomTheme
                                                    .smallTextStyleColored,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                    onTap: () {
                                      if (_formKey.currentState!.validate()) {
                                        isLoading = true;
                                        bloc.add(LoginCompletingStarted());
                                        bloc.add(LoginCompleting(
                                          email: loginEmailController.text,
                                          password:
                                              loginPasswordController.text,
                                        ));
                                      }
                                    },
                                    child: signupSubmitButton(
                                        iconPath: 'login_submit')),
                              ],
                            ),
                            SizedBox(height: 50.0),
                            /*google ,fb and phon auth button*/
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                if (Config.enableGoogleAuth)
                                  firebaseAuthWidgets(
                                      "google", authService, _signInWithGoogle),
                                if (Config.enableFacebookAuth)
                                  // firebaseAuthWidgets("fb",authService,_fbLogin),
                                  // Phone Auth Available Only for Android
                                  if (Config.enablePhoneAuth)
                                    GestureDetector(
                                      child: googleFbPhoneButton('phone'),
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, PhoneAuthScreen.route);
                                      },
                                    ),
                                if (Platform.isIOS &&
                                    Config.enableAppleAuthForIOS)
                                  firebaseAuthWidgets("apple_login_icon",
                                      authService, _signInWithApple),
                              ],
                            ),
                            SizedBox(height: 50.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (isLoading) spinkit,
            ],
          ));
        },
      ),
    );
  }

  Widget _renderResetPassword() {
    return GestureDetector(
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: new Text(
                  helper.getTranslated(context, AppTags.resetPassword)!,
                ),
                content: resetPassAlartContent(),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(15)),
                actionsPadding: EdgeInsets.only(right: 15.0),
                actions: <Widget>[
                  GestureDetector(
                      onTap: () {
                        if (resetPassFormKey.currentState!.validate())
                          resetPassword(
                              context, resetPassEmailController.value.text);
                      },
                      child: HelpMe().accountDeactivate(
                          60, helper.getTranslated(context, AppTags.yesText)!,
                          height: 30.0)),
                  GestureDetector(
                      onTap: () {
                        cancenResetPass(context);
                      },
                      child: HelpMe().submitButton(
                          60, helper.getTranslated(context, AppTags.noText)!,
                          height: 30.0)),
                ],
              );
            });
      },
      child: Text(
        helper.getTranslated(context, AppTags.resetPassword)!,
        style: CustomTheme.smallTextStyleColoredUnderLine,
      ),
    );
  }

  Widget resetPassAlartContent() {
    return Container(
      child: Form(
        key: resetPassFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              helper.getTranslated(context, AppTags.preceedResetPassword)!,
              style: CustomTheme.subTitleText,
            ),
            SizedBox(
              height: 10.0,
            ),
            EditTextUtils().getCustomEditTextField(
                hintValue: helper.getTranslated(context, AppTags.emailAddress),
                keyboardType: TextInputType.emailAddress,
                controller: resetPassEmailController,
                prefixWidget: Image.asset(
                  'assets/images/common/email.png',
                  scale: 2.5,
                ),
                style: CustomTheme.textFieldTitle,
                validator: (value) {
                  return validateEmail(value);
                }),
          ],
        ),
      ),
    );
  }

  /*reset password function*/
  resetPassword(context, String userEmail) async {
    passwordResetModel = await Repository().passResetResponse(email: userEmail);
    if (passwordResetModel != null) {
      Navigator.of(context).pop();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Text(
                  "${helper.getTranslated(context, AppTags.checkEmail)} $userEmail "),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(15)),
              actionsPadding: EdgeInsets.only(right: 15.0),
              actions: <Widget>[
                GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      resetPassEmailController.clear();
                    },
                    child: HelpMe().submitButton(
                        60, helper.getTranslated(context, AppTags.okText)!,
                        height: 30.0)),
              ],
            );
          });
    } else {
      showShortToast(helper.getTranslated(context, AppTags.provideValidEmail)!);
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });
    }
  }

  //cancel accountDeactivate
  cancenResetPass(context) {
    resetPassEmailController.clear();
    Navigator.of(context).pop();
  }

  Widget firebaseAuthWidgets(String iconPath, authService, Function function) {
    return BlocListener<FirebaseAuthBloc, FirebaseAuthState>(
      listener: (context, state) {
        if (state is FirebaseAuthStateCompleted) {
          AuthUser? user = state.getUser;
          if (user == null) {
            firebaseAuthBloc.add(FirebaseAuthFailed);
          }
          authService.updateUser(user);
          isLoading = false;
          if (authService.getUser() != null) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => MainScreen()),
                (Route<dynamic> route) => false);
          }
        } else if (state is FirebaseAuthFailedState) {
          firebaseAuthBloc.add(FirebaseAuthNotStarted());
        }
      },
      child: BlocBuilder<FirebaseAuthBloc, FirebaseAuthState>(
        builder: (context, state) {
          return GestureDetector(
              onTap: () async {
                setState(() {
                  isLoading = true;
                });
                User fbUser = await function();
                firebaseAuthBloc.add(FirebaseAuthStarted());
                firebaseAuthBloc.add(FirebaseAuthCompleting(
                  uid: fbUser.uid,
                  email: fbUser.email,
                  phone: fbUser.phoneNumber,
                ));
              },
              child: googleFbPhoneButton(iconPath));
        },
      ),
    );
  }

  // ignore: missing_return
  Future<User> _signInWithGoogle() async {
    final GoogleSignInAccount googleUser =
        await (_googleSignIn.signIn() as FutureOr<GoogleSignInAccount>);
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final User user = (await _auth.signInWithCredential(credential)).user!;
    //print(user.email);
    if (user.email != null && user.email != "") {
      assert(user.email != null);
    }
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = await _auth.currentUser!;
    assert(user.uid == currentUser.uid);
    return user;
  }

  //Facebook login
  /*Future<bool> signInWithFacebook() async {
    final  AccessToken token;
    final existingToken = await FacebookAuth.instance.accessToken;
    if (existingToken != null) {
      //token already exist
      token = existingToken;

      return await _fbLogin(token);
    } else {
      //token null, try to new login
      final result = await FacebookAuth.instance.login(
        permissions: [
          'email',
          // 'public_profile',
          'first_name',
          'image',
        ],
        loginBehavior: LoginBehavior.DIALOG_ONLY,
      );
      if (result.status == LoginStatus.success && result.accessToken != null) {
        token = result.accessToken!;

        return await _fbLogin(token);
      } else {
        return false;
      }
    }
  }

  // ignore: missing_return
  Future<User> _fbLogin() async {
    final FacebookLoginResult result = await facebookSignIn.logIn(['email','public_profile']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        final AuthCredential credential = FacebookAuthProvider.credential( accessToken.token);
        final User user = (await _auth.signInWithCredential(credential)).user;
        if(user.email != null && user.email != ""){
          assert(user.email != null);
        }
        if(user.phoneNumber != null){
          assert(user.phoneNumber != null);
        }
        assert(user.displayName != null);
        assert(!user.isAnonymous);
        assert(await user.getIdToken() != null);
        final User currentUser = await _auth.currentUser;
        assert(user.uid == currentUser.uid);
        if (user != null) return user;
        break;
      case FacebookLoginStatus.cancelledByUser:
      //print(AppContent.loginCancelled);
        return null;
        break;
      case FacebookLoginStatus.error:
        print('Something went wrong with the login process.\n'
            'Here\'s the error Facebook gave us: ${result.errorMessage}');
        return null;
        break;
    }
  }*/

  // ignore: missing_return
  Future<User> _signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    print(appleCredential.authorizationCode);
    final OAuthProvider oAuthProvider = OAuthProvider('apple.com');
    final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode);
    final User user = (await _auth.signInWithCredential(credential)).user!;
    //print(user.email);
    if (user.email != null && user.email != "") {
      assert(user.email != null);
    }
    if (user.displayName != null && user.displayName != "") {
      assert(user.displayName != null);
    }
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = await _auth.currentUser!;
    assert(user.uid == currentUser.uid);
    return user;
  }
}
