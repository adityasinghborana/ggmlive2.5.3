const kLOG_TAG = "[MeetAir]";
const kLOG_ENABLE = true;

printLog(dynamic data) {
  if (kLOG_ENABLE) {
    print("hello >>>$kLOG_TAG${data.toString()}");
  }
}