import 'package:flutter/material.dart';

class Config {
  // copy your api url from php admin dashboard & paste below
  static final String baseUrl             = "https://meetair.spagreen.net/demo/app/v100/";
  //copy your api key from php admin dashboard & paste below
  static final String apiKey              = "hn141zghgkskv1gi0br1lr9z";
  //
  static final String oneSignalAppID      = "xxxxxxxxxxxxxxxxxxxxx-xxxxxx";

  static final bool enableFacebookAuth    = false;
  static final bool enableGoogleAuth      = true;
  static final bool enablePhoneAuth       = true;
  static final bool enableAppleAuthForIOS = true;
  static final String defaultLanguage     = "en";



  //supported language list
  static var supportedLanguageList = [
    Locale("en", "US"),
    Locale("ar", "SA"),
    Locale("bn", "BD")
  ];//supported language list

}
/// the welcome screen data
List introContent = [
  {
    "title": "Welcome To",
    "image": "assets/images/introImage/intro_slide_one.png",
    "desc": "Start or join a video meeting on the go"
  },
  {
    "title": "Message Your Team",
    "image": "assets/images/introImage/intro_slide_one.png",
    "desc": "Send text, voice message and share file"
  },
  {
    "title": "Get MeetAiring",
    "image": "assets/images/introImage/intro_slide_one.png",
    "desc": "Work anywhere, with anyone, one any device"
  }
];
List introContentBn = [
  {
    "title": "স্বাগতম",
    "image": "assets/images/introImage/intro_slide_one.png",
    "desc": "যেতে যেতে ভিডিও মিটিং শুরু করুন বা যোগ দিন"
  },
  {
    "title": "আপনার টিম বার্তা",
    "image": "assets/images/introImage/intro_slide_one.png",
    "desc": "পাঠ্য, ভয়েস বার্তা পাঠান এবং ফাইল শেয়ার করুন"
  },
  {
    "title": "মিট এয়ারিং পান",
    "image": "assets/images/introImage/intro_slide_one.png",
    "desc": "যেকোন জায়গায়, যে কারো সাথে, যেকোন ডিভাইসে কাজ করুন"
  }
];
List introContentAr = [
  {
    "title": "مرحبا بك في",
    "image": "assets/images/introImage/intro_slide_one.png",
    "desc": "ابدأ أو انضم إلى اجتماع فيديو أثناء التنقل"
  },
  {
    "title": "أرسل رسالة إلى فريقك",
    "image": "assets/images/introImage/intro_slide_one.png",
    "desc": "إرسال رسالة نصية وصوتية ومشاركة الملف"
  },
  {
    "title": "احصل على يجتمع بث",
    "image": "assets/images/introImage/intro_slide_one.png",
    "desc": "العمل في أي مكان ، مع أي شخص ، مع جهاز واحد وأي جهاز"
  }
];