import 'package:admob_flutter/admob_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:spagreen/src/models/get_config_model.dart';
import 'package:spagreen/src/models/user_model.dart';
import 'package:spagreen/src/server/repository.dart';
import 'app.dart';
import 'src/services/get_config_service.dart';
import 'dart:io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);
  Hive.registerAdapter(GetConfigModelAdapter());
  Hive.registerAdapter(AppConfigAdapter());
  Hive.registerAdapter(AdsConfigAdapter());
  Hive.registerAdapter(AuthUserAdapter());
  await Hive.openBox<GetConfigModel?>('getConfigbox');
  await Hive.openBox<AppConfig>('appConfigbox');
  await Hive.openBox<AdsConfig>('adsConfigbox');
  await Hive.openBox<AuthUser>('user');
  await Hive.openBox('seenBox');
  await Hive.openBox("languageCode");
  await Hive.openBox("language");
  GetConfigModel? getConfigModel;
  getConfigModel = await Repository().getAppConfig();
  GetConfigService().updateGetConfig(getConfigModel);
  Admob.initialize();
  runApp(MyApp());
}

String? getAppId(AdsConfig adsConfig) {
  if (Platform.isIOS) {
    print(adsConfig.admobAppId);
    return adsConfig.admobAppId;
  } else if (Platform.isAndroid) {
    return adsConfig.admobAppId;
  }
  return null;
}
