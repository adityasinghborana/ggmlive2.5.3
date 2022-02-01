import 'package:app_review/app_review.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:spagreen/app.dart';
import 'package:spagreen/config.dart';
import 'package:spagreen/constants.dart';
import 'package:spagreen/src/button_widget.dart';
import 'package:spagreen/src/models/Language.dart';
import 'package:spagreen/src/models/user_model.dart';
import 'package:spagreen/src/services/authentication_service.dart';
import 'package:spagreen/src/services/get_config_service.dart';
import 'package:spagreen/src/style/theme.dart';
import 'package:spagreen/src/utils/app_tags.dart';
import 'package:spagreen/src/utils/validators.dart';
import 'package:spagreen/src/widgets/edit_and_send_invitation_btn.dart';
import 'package:spagreen/src/widgets/user_info_card.dart';
import 'package:spagreen/src/widgets/privacy_policy_screen.dart';
import '../widgets/setting_widget_without_login.dart';
import 'package:package_info/package_info.dart';
import '../utils/localization_helper.dart' as helper;

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  GetConfigService? configService;
  late AuthService authService;
  bool? ismandatoryLogin;
  AuthUser? authUser =  AuthService().getUser() != null ? AuthService().getUser() : null;
  String? output = "";
  PackageInfo _packageInfo = PackageInfo(
    appName: 'AppName',
    version: 'Unknown',
    buildNumber: 'Unknown', packageName: '',
  );
  String? joinWebUrl;
  String? linkMessage;
  final _auth = FirebaseAuth.instance;


  String? selectedLanguage;
  //String selectedLanguage = Config.defaultLanguage=="en"?"English":Config.defaultLanguage=="bn"?"Bangla":Config.defaultLanguage=="ar"?"اَلْعَرَبِيَّة":"Select Your Language";

  void _changeLanguage(Languages language) {
    Locale _locale = helper.setLocal(language.code);
     MyApp.setLocal(context, _locale);
  }

  ///authUserUpdated will be called from edit profile screen if user update user info.
  void authUserUpdated(){
    if (this.mounted){
      setState((){});
    }
   }

  @override
  initState() {
    super.initState();
    selectedLanguage = getSelectedLanguage();
    _initPackageInfo();
    if(authUser != null){
    }
  }

  String getSelectedLanguage() {
    var box = Hive.box("language");
    String? value = box.get("language");
    if (value != null) {
      return value;
    }
    //return "العربية";
    return Config.defaultLanguage=="en"?"English":Config.defaultLanguage=="bn"?"বাংলা":"اَلْعَرَبِيَّة";
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }
  @override
  Widget build(BuildContext context) {
    printLog('SeetingScreen');
    authService = Provider.of<AuthService>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _renderAppBar(),
                if(authUser != null )
                  userInfoCard(authUser!, context,authUserUpdated),
                if(authUser != null)
                  logoutSection(),
                if(authUser != null )
                  _renderPersonalMeetingCard( authUser!),
                if(authUser == null)
                  SeetingWidgetWithoutLogin(),
                appThemeVersionPrivacy(context),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Text(
                    helper.getTranslated(context, AppTags.copyrightText)!,
                    textAlign: TextAlign.center,
                    style: CustomTheme.smallTextStyleRegular,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _renderAppBar() {
    return Container(
      width: MediaQuery.of(context).size.width,

      child: Padding(
        padding: const EdgeInsets.only(top: 40, bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          //mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              helper.getTranslated(context, AppTags.titleSettingsScreen)!,
              style: CustomTheme.screenTitle,
            ),
            Text(
              helper.getTranslated(context, AppTags.subTitleSettingsScreen)!,
              style: CustomTheme.displayTextOne,
            )
          ],
        ),
      ),
    );
  }

  Widget _renderPersonalMeetingCard(AuthUser authUser) {
    joinWebUrl =  "${Config.baseUrl}room/${authUser.meetingCode}";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 25.0, bottom: 25.0, right: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(helper.getTranslated(context, AppTags.myPersonalMeetingID)!, style: CustomTheme.displayTextBoldPrimaryColor),
              SizedBox(height: 30.0),

              Container(
                height: 44.0,
                decoration: new BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(3.0)),
                  border: Border.all(color: CustomTheme.lightColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(children: <Widget>[
                        Image.asset('assets/images/common/hash.png', width: 12, height: 16, scale: 3),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(authUser.meetingCode, style: CustomTheme.textFieldTitlePrimaryColored,),
                        ),
                      ],),
                      GestureDetector(
                          onTap: () {
                            Clipboard.setData(new ClipboardData(text: authUser.meetingCode)).then((_){
                              showShortToast(helper.getTranslated(context, AppTags.meetingIDcopied)!,);
                            });
                          },
                          child: Icon(Icons.content_copy,color: CustomTheme.primaryColor,)),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 14),
              sendInvitation(context: context, title: helper.getTranslated(context, AppTags.sendInvitation)!, meetingCode: linkMessage,),
            ],
          ),
        ),
        decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          boxShadow: CustomTheme.boxShadow,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget appThemeVersionPrivacy(context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            onTap: () {
              AppReview.storeListing.then((onValue) {
                setState(() {
                  output = onValue;});
                print(onValue);
              });
            },
            contentPadding: const EdgeInsets.symmetric(
                vertical: 0.0, horizontal: 20.0),
            title: Text(helper.getTranslated(context, AppTags.rateAndReview)!, style: CustomTheme.displayTextOne,
            ),
            trailing: Image.asset('assets/images/common/arrow_forward.png', scale: 2.5,),
          ),
          Divider(
            color: CustomTheme.grey,
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
                vertical: 0.0, horizontal: 20.0),
            title: Text(
              helper.getTranslated(context, AppTags.version)!,
              style: CustomTheme.displayTextOne,
            ),
            trailing: Text(
              "${_packageInfo.version}(${_packageInfo.buildNumber})",
              style: CustomTheme.displayTextOne,
            ),
          ),


          Divider(
            color: CustomTheme.grey,
          ),

          ListTile(
            contentPadding: const EdgeInsets.symmetric(
                vertical: 0.0, horizontal: 20.0),
            onTap: () {
              Navigator.pushNamed(context, PrivacyPolicyScreen.route);
            },
            title: Text(
              helper.getTranslated(context, AppTags.privacyPolicy)!,
              style: CustomTheme.displayTextOne,
            ),
            trailing: Image.asset(
              'assets/images/common/arrow_forward.png',
              scale: 2.5,
            ),
          ),

          //Language_settings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(helper.getTranslated(context, AppTags.language)!, style: CustomTheme.displayTextOne,),
              ),
              Container(
                child: Center(
                    child: DropdownButton<Languages>(
                      isExpanded: false,
                      underline: SizedBox(),
                      icon: Icon(
                        Icons.arrow_drop_down_outlined,
                      ),
                      hint: Container(
                        width: 60,
                        child: Center(
                          child: Text(
                            selectedLanguage!,
                            style: CustomTheme.displayTextOne,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedLanguage = value!.name;
                          print("------------language: ${value.name}");
                          print("------------language code: ${value.code}");
                        });
                        saveSelectedLanguageCode(value!.code);
                        saveSelectedLanguage(value.name);
                        _changeLanguage(value);
                      },
                       items: Languages.languageList().map((e) => DropdownMenuItem<Languages>(value: e, child: Text(e.name!),),).toList(),
                      // items: Config.defaultLanguage=="en"? Languages.languageListEn().map((e) => DropdownMenuItem<Languages>(value: e, child: Text(e.name),),).toList():
                      //     Config.defaultLanguage=="bn"?Languages.languageListBn().map((e) => DropdownMenuItem<Languages>(value: e, child: Text(e.name),),).toList():
                      //         Config.defaultLanguage=="ar"?Languages.languageListAr().map((e) => DropdownMenuItem<Languages>(value: e, child: Text(e.name),),).toList():
                      //         Languages.languageList().map((e) => DropdownMenuItem<Languages>(value: e, child: Text(e.name),),).toList(),
                    )
                ),
              )
            ],
          ),
        ],
      ),
      decoration: new BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        boxShadow: CustomTheme.boxShadow,
        color: Colors.white,
      ),
    );
  }

  saveSelectedLanguageCode(String? languageCode) {
    Box box = Hive.box("languageCode");
    box.put("languageCode", languageCode);
  }

  saveSelectedLanguage(String? languageName) {
    Box box = Hive.box("language");
    box.put("language", languageName);
  }


  Widget logoutSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: GestureDetector(
        onTap: (){
          showDialog(context: context,
              builder: (BuildContext context){
                return AlertDialog(
                  content:  Text(helper.getTranslated(context, AppTags.areYouSureLogout)!,),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(15)),
                  actionsPadding: EdgeInsets.only(right: 15.0),
                  actions: <Widget>[
                    GestureDetector(
                        onTap: ()async{
                          await _auth.signOut();
                          if(authService.getUser() != null)
                            authService.deleteUser();
                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                              MyApp()), (Route<dynamic> route) => false);},
                        child: HelpMe().accountDeactivate(60, helper.getTranslated(context, AppTags.yesText)!,height: 30.0)),
                    SizedBox(width: 8.0,),
                    GestureDetector(
                        onTap: (){
                          Navigator.of(context).pop();
                        },
                        child: HelpMe().submitButton(60, helper.getTranslated(context, AppTags.noText)!,height: 30.0)),
                  ],
                );
              }
          );
        },
        child: Container(
          child: Column(
            children: <Widget>[
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 0.0, horizontal: 20.0),
                title: Text(helper.getTranslated(context, AppTags.logout)!, style: CustomTheme.alartTextStyle,),
              ),
            ],
          ),
          decoration: new BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            boxShadow: CustomTheme.boxShadow,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

