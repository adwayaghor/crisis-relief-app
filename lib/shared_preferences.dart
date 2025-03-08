import 'package:shared_preferences/shared_preferences.dart';

bool logStatus = false;
bool adminLog = false;
String universalId = 'Sign Up/ Login to view details';
String name = '';
bool isNGO = false;
String language = 'English';

Future<void> loadLangStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  language = prefs.getString('language') ?? 'English';
}

Future<void> saveLangStatus(String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('language', value);
}

Future<void> loadIDStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  universalId =
      prefs.getString('universalId') ?? 'Sign Up/ Login to view details';
}

Future<void> saveIDStatus(String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('universalId', value);
}

Future<void> loadisNGOStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  isNGO = prefs.getBool('isNGO') ?? false;
}

Future<void> saveisNGOStatus(bool status) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isNGO', status);
}

Future<void> loadNameStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  name = prefs.getString('name') ?? '';
}

Future<void> saveNameStatus(String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('name', value);
}

Future<void> loadLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  logStatus = prefs.getBool('logStatus') ?? false;
}

Future<void> saveLoginStatus(bool status) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('logStatus', status);
}

Future<void> loadAdminStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  adminLog = prefs.getBool('adminLog') ?? false;
}

Future<void> saveAdminStatus(bool status) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('adminLog', status);
}
