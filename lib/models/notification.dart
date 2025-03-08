import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotiServcie{
  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool get isinitialized{
    return _initialized;
  }
  Future<void> initNotification()async{
    if(_initialized){
      return;
    }
    const initsettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(
      android: initsettingsAndroid
    );
    await notificationsPlugin.initialize(initSettings);
  }
  NotificationDetails notificationDetails(){
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id', 
        'Daily Notifications',
        channelDescription: 'Daily Notification Channel',
        importance: Importance.max,
        priority: Priority.high
      )
    );
  }
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? description
  })async{
    return notificationsPlugin.show(id, title, description, notificationDetails());
  }
}