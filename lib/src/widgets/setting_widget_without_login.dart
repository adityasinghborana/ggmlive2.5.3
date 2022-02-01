import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spagreen/src/utils/app_tags.dart';
import '../button_widget.dart';
import '../strings.dart';
import '../style/theme.dart';
import '../screen/login_screen.dart';
import '../utils/localization_helper.dart' as helper;


class SeetingWidgetWithoutLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 20,
        ),
        Image.asset(
          'assets/images/common/default_user_profile.png',
          width: 146,
          height: 146,
        ),
        Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Text(
            helper.getTranslated(context, AppTags.loginToAccessProfile)!,
            style: CustomTheme.displayTextOne,
            textAlign: TextAlign.center,
          ),
        ),
        GestureDetector(
            onTap: (){
              Navigator.pushNamed(context, LoginPage.route);
            },
            child: HelpMe().submitButton(142,helper.getTranslated(context, AppTags.login)!,)),
        SizedBox(
          height: 45,
        ),
      ],
    );
  }
}