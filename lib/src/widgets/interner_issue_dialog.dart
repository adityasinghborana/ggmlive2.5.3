import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spagreen/src/style/theme.dart';
import 'package:spagreen/src/utils/app_tags.dart';
import '../utils/localization_helper.dart' as helper;


Future<dynamic> showDialogNotInternet(BuildContext context) {
  return showDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: Center(
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Icon(Icons.warning,color: CustomTheme.redColor,),
              ),
              Text(helper.getTranslated(context, AppTags.internetIssue)!,style: CustomTheme.displayErrorText,),
            ],
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(helper.getTranslated(context, AppTags.checkInternetConnection)!,style: CustomTheme.displayTextColoured,),
        ),
      )

  );
}
