import 'package:get_storage/get_storage.dart';
import 'package:neffils/utils/constants.dart';
// import 'package:neffils/utlis/constants.dart';

class UserPreferences {
  final GetStorage box = GetStorage();

  // Get login status
  // static bool getLoginStatus() {
  //   bool ls;
  //   if (GetStorage().read(Constants.userLoggedIn) == null) {
  //     ls = false;
  //   } else {
  //     ls = GetStorage().read(Constants.userLoggedIn);
  //   }
  //   return ls;
  // } // Set login status

  // Future<void> setLoginStatus(bool value) {
  //   return box.write(Constants.userLoggedIn, value);
  // }

  // Storing data with key locally
  static void setStorageData({required String key, dynamic value}) =>
      GetStorage().write(key, value);

  // Fetching int value from local storage
  static int? getStorageInt(String key) => GetStorage().read(key);

  // Fetching string value from local storage
  static String? getStorageString(String key) => GetStorage().read(key);

  // Fetching bool value from local storage
  static bool? getStorageBool(String key) => GetStorage().read(key);

  // Fetching double value from local storage
  static double? getStorageDouble(String key) => GetStorage().read(key);

  // Fetching data value from local storage
  static dynamic getStorageData(String key) => GetStorage().read(key);

  static void clearStorageData() async => GetStorage().erase();
}
