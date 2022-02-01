import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:spagreen/src/bloc/phone_auth/phone_auth_bloc.dart';
import 'package:spagreen/src/bloc/phone_auth/phone_auth_event.dart';
import 'package:spagreen/src/utils/app_tags.dart';
import '../button_widget.dart';
import '../utils/localization_helper.dart' as helper;


class OtpInput extends StatelessWidget {
  String? inputPin;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ConstrainedBox(
      child: Padding(
        padding: const EdgeInsets.only(
            top: 48.0, bottom: 16.0, left: 16.0, right: 16.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                helper.getTranslated(context, AppTags.enterTheCodeSent)!,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            PinPut(
                fieldsCount: 6,
                onSubmit: (String pin) {
                  inputPin = pin;
                }),
            SizedBox(height: 30.0),
            GestureDetector(
                onTap: () {
                  BlocProvider.of<PhoneAuthBloc>(context).add(VerifyOtpEvent(otp: inputPin));},
                child: HelpMe().submitButton(142, helper.getTranslated(context, AppTags.submit)!,)),
          ],
        ),
      ),
      constraints: BoxConstraints.tight(Size.fromHeight(250)),
    );
  }
}