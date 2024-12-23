import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

void startBackgroundService() {
  FlutterBackgroundService().configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onServiceStarted,
      isForegroundMode: true,
      autoStart: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onServiceStarted,
    ),
  );
}

void onServiceStarted(ServiceInstance service) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  int timerDuration = prefs.getInt('timerDuration') ?? 0;

  bool isServiceRunning = true; // Manually track the running state

  service.on('start_timer').listen((event) async {
    while (isServiceRunning) {
      await Future.delayed(const Duration(seconds: 1));
      timerDuration++;
      prefs.setInt('timerDuration', timerDuration);
      print('Background Timer: $timerDuration');
    }
  });

  // Stop the service manually
  service.on('stop_service').listen((event) {
    isServiceRunning = false; // Update the running state
    service.stopSelf();
    print('Service stopped.');
  });
}

//2
// void backgroundService() {
//   FlutterBackgroundService.initialize(onServiceStarted);
// }

// void onServiceStarted(ServiceInstance service) async {
//   if (service is AndroidServiceInstance) {
//     service.on('start_timer').listen((event) async {
//       final SharedPreferences prefs = await SharedPreferences.getInstance();
//       int timerDuration = prefs.getInt('timerDuration') ?? 0;

//       while (true) {
//         await Future.delayed(const Duration(seconds: 1));
//         timerDuration++;
//         prefs.setInt('timerDuration', timerDuration);
//         print('Background Timer: $timerDuration');
//       }
//     });
//   }
// }

// 1

// void backgroundService() async {
//   final service = FlutterBackgroundService();
  
//   // Called when the background service is initialized
//   service.onDataReceived.listen((event) async {
//     if (event!["action"] == "start_timer") {
//       startTimerInBackground();
//     }
//   });

//   // Start the service in the background
//   await service.configure(
//     androidConfiguration: AndroidConfiguration(
//       onStart: onServiceStarted,
//       autoStart: true,
//       isInForegroundMode: true,
//     ),
//     iosConfiguration: IosConfiguration(onForeground: onServiceStarted),
//   );
// }

// void onServiceStarted() async {
//   final SharedPreferences prefs = await SharedPreferences.getInstance();
//   int timerDuration = prefs.getInt('timerDuration') ?? 0;

//   // Timer runs in the background and keeps saving the time.
//   while (true) {
//     await Future.delayed(Duration(seconds: 1));
//     timerDuration++;
//     prefs.setInt('timerDuration', timerDuration);
//     print('Background Timer: $timerDuration');
//   }
// }

// void startTimerInBackground() {
//   final service = FlutterBackgroundService();
//   service.invoke("start_timer");
// }
