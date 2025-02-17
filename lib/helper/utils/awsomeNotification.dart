import 'package:project/helper/utils/generalImports.dart';

class LocalAwesomeNotification {
  static AwesomeNotifications? notification = AwesomeNotifications();

  static FirebaseMessaging? messagingInstance = FirebaseMessaging.instance;

  static LocalAwesomeNotification? localNotification =
      LocalAwesomeNotification();

  static late StreamSubscription<RemoteMessage>? foregroundStream;

  final List<int> highIntensityVibrationPattern = [0, 500, 200, 500]; // Example

  static late StreamSubscription<RemoteMessage>? onMessageOpen;

  init(BuildContext context) async {
    if (notification != null &&
        messagingInstance != null &&
        localNotification != null) {
      disposeListeners().then((value) async {
        await requestPermission(context: context);
        notification = AwesomeNotifications();
        messagingInstance = FirebaseMessaging.instance;
        localNotification = LocalAwesomeNotification();

        await registerListeners(context);

        await listenTap(context);

        await notification?.initialize(
          'resource://mipmap/logo',
          [
            NotificationChannel(
              channelKey: "basic_notifications",
              channelName: 'Basic notifications',
              channelDescription: 'Notification channel',
              playSound: true,
              enableVibration: true,
              importance: NotificationImportance.High,
              ledColor: ColorsRes.appColor,
            )
          ],
          channelGroups: [
            NotificationChannelGroup(
                channelGroupKey: "Basic notifications",
                channelGroupName: 'Basic notifications')
          ],
          debug: kDebugMode,
        );
      });
    } else {
      await requestPermission(context: context);
      notification = AwesomeNotifications();
      messagingInstance = FirebaseMessaging.instance;
      localNotification = LocalAwesomeNotification();
      await registerListeners(context);

      await listenTap(context);

      await notification?.initialize(
        'resource://mipmap/logo',
        [
          NotificationChannel(
            channelKey: "basic_notifications",
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel',
            playSound: true,
            enableVibration: true,
            importance: NotificationImportance.High,
            ledColor: ColorsRes.appColor,
          )
        ],
        channelGroups: [
          NotificationChannelGroup(
              channelGroupKey: "Basic notifications",
              channelGroupName: 'Basic notifications')
        ],
        debug: kDebugMode,
      );
    }
  }

  requestNotificationPermission(BuildContext context) async {
    if (notification != null &&
        messagingInstance != null &&
        localNotification != null) {
      disposeListeners().then((value) async {
        await requestPermission(context: context);
        notification = AwesomeNotifications();
        messagingInstance = FirebaseMessaging.instance;
        localNotification = LocalAwesomeNotification();
        await registerListeners(context);
        await notification?.initialize(
          'resource://mipmap/logo',
          [
            NotificationChannel(
              channelKey: "basic_notifications",
              channelName: 'Basic notifications',
              channelDescription: 'Notification channel',
              playSound: true,
              enableVibration: true,
              importance: NotificationImportance.High,
              ledColor: ColorsRes.appColor,
            )
          ],
          channelGroups: [
            NotificationChannelGroup(
                channelGroupKey: "Basic notifications",
                channelGroupName: 'Basic notifications')
          ],
          debug: kDebugMode,
        );
      });
    } else {
      await requestPermission(context: context);
      notification = AwesomeNotifications();
      messagingInstance = FirebaseMessaging.instance;
      localNotification = LocalAwesomeNotification();
      await registerListeners(context);

      await notification?.initialize(
        'resource://mipmap/logo',
        [
          NotificationChannel(
            channelKey: "basic_notifications",
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel',
            playSound: true,
            enableVibration: true,
            importance: NotificationImportance.High,
            ledColor: ColorsRes.appColor,
          )
        ],
        channelGroups: [
          NotificationChannelGroup(
              channelGroupKey: "Basic notifications",
              channelGroupName: 'Basic notifications')
        ],
        debug: kDebugMode,
      );
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onActionNotificationMethod(ReceivedAction data) async {
    String notificationTypeId = data.payload!["id"].toString();
    String notificationType = data.payload!["type"].toString();

    Future.delayed(
      Duration.zero,
      () {
        if (notificationType == "default" || notificationType == "user") {
          if (currentRoute != notificationListScreen) {
            Navigator.pushNamed(
              navigatorKey.currentContext!,
              notificationListScreen,
            );
          }
        } else if (notificationType == "category") {
          Navigator.pushNamed(
            navigatorKey.currentContext!,
            productListScreen,
            arguments: [
              "category",
              notificationTypeId.toString(),
              getTranslatedValue(navigatorKey.currentContext!, "app_name")
            ],
          );
        } else if (notificationType == "product") {
          Navigator.pushNamed(
            navigatorKey.currentContext!,
            productDetailScreen,
            arguments: [
              notificationTypeId.toString(),
              getTranslatedValue(navigatorKey.currentContext!, "app_name"),
              null
            ],
          );
        } else if (notificationType == "url") {
          launchUrl(
            Uri.parse(
              notificationTypeId.toString(),
            ),
            mode: LaunchMode.externalApplication,
          );
        }
      },
    );
  }

  static listenTap(BuildContext context) {
    try {
      notification?.setListeners(
          onDismissActionReceivedMethod: (receivedAction) async {},
          onNotificationDisplayedMethod: (receivedNotification) async {},
          onNotificationCreatedMethod: (receivedNotification) async {},
          onActionReceivedMethod: onActionNotificationMethod);
    } catch (e) {
      if (kDebugMode) {
        debugPrint("ERROR IS ${e.toString()}");
      }
    }
  }

  createImageNotification(
      {required RemoteMessage data, required bool isLocked}) async {
    try {
      await notification?.createNotification(
        content: NotificationContent(
          id: Random().nextInt(5000),
          color: ColorsRes.appColor,
          title: data.data["title"],
          locked: isLocked,
          payload: Map.from(data.data),
          autoDismissible: true,
          showWhen: true,
          notificationLayout: NotificationLayout.BigPicture,
          body: data.data["message"],
          wakeUpScreen: true,
          largeIcon: data.data["image"],
          bigPicture: data.data["image"],
          channelKey: "basic_notifications",
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint("ERROR IS ${e.toString()}");
      }
    }
  }

  createNotification(
      {required RemoteMessage data, required bool isLocked}) async {
    try {
      await notification?.createNotification(
        content: NotificationContent(
          id: Random().nextInt(5000),
          color: ColorsRes.appColor,
          title: data.data["title"],
          locked: isLocked,
          payload: Map.from(data.data),
          autoDismissible: true,
          showWhen: true,
          notificationLayout: NotificationLayout.Default,
          body: data.data["message"],
          wakeUpScreen: true,
          channelKey: "basic_notifications",
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint("ERROR IS ${e.toString()}");
      }
    }
  }

  requestPermission({required BuildContext context}) async {
    try {
      PermissionStatus notificationPermissionStatus =
          await Permission.notification.status;

      if (notificationPermissionStatus.isPermanentlyDenied) {
        if (!Constant.session.getBoolData(
            SessionManager.keyPermissionNotificationHidePromptPermanently)) {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Wrap(
                children: [
                  PermissionHandlerBottomSheet(
                    titleJsonKey: "notification_permission_title",
                    messageJsonKey: "notification_permission_message",
                    sessionKeyForAskNeverShowAgain: SessionManager
                        .keyPermissionNotificationHidePromptPermanently,
                  ),
                ],
              );
            },
          );
        }
      } else if (notificationPermissionStatus.isDenied) {
        await messagingInstance?.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        Permission.notification.request();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("ERROR IS ${e.toString()}");
      }
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onBackgroundMessageHandler(RemoteMessage data) async {
    try {
      if (Platform.isAndroid) {
        if (data.data["image"] == "" || data.data["image"] == null) {
          localNotification?.createNotification(isLocked: false, data: data);
        } else {
          localNotification?.createImageNotification(
              isLocked: false, data: data);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("ISSUE ${e.toString()}");
      }
    }
  }

  static foregroundNotificationHandler() async {
    try {
      onMessageOpen =
          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (Platform.isAndroid) {
          if (message.data["image"] == "" || message.data["image"] == null) {
            localNotification?.createNotification(
                isLocked: false, data: message);
          } else {
            localNotification?.createImageNotification(
                isLocked: false, data: message);
          }
        }
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint("ISSUE ${e.toString()}");
      }
    }
  }

  static terminatedStateNotificationHandler() async {
    try {
      RemoteMessage? message = await messagingInstance?.getInitialMessage();

      if (message == null) {
        return;
      }

      // Use a more robust navigation method
      Future.delayed(Duration.zero, () {
        _handleNotificationNavigation(message);
      });

      // Create notification as before
      if (message.data["image"] == "" || message.data["image"] == null) {
        localNotification?.createNotification(isLocked: false, data: message);
      } else {
        localNotification?.createImageNotification(
            isLocked: false, data: message);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Terminated State Handler Error: ${e.toString()}");
      }
    }
  }

  static void _handleNotificationNavigation(RemoteMessage message) {
    String notificationTypeId = message.data["id"].toString();
    String notificationType = message.data["type"].toString();

    if (notificationType == "default" || notificationType == "user") {
      Navigator.pushNamed(
        navigatorKey.currentContext!,
        notificationListScreen,
      );
    } else if (notificationType == "category") {
      Navigator.pushNamed(
        navigatorKey.currentContext!,
        productListScreen,
        arguments: [
          "category",
          notificationTypeId.toString(),
          getTranslatedValue(navigatorKey.currentContext!, "app_name")
        ],
      );
    } else if (notificationType == "product") {
      Navigator.pushNamed(
        navigatorKey.currentContext!,
        productDetailScreen,
        arguments: [
          notificationTypeId.toString(),
          getTranslatedValue(navigatorKey.currentContext!, "app_name"),
          null
        ],
      );
    } else if (notificationType == "url") {
      launchUrl(
        Uri.parse(notificationTypeId.toString()),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  static registerListeners(context) async {
    try {
      FirebaseMessaging.onBackgroundMessage(onBackgroundMessageHandler);
      messagingInstance?.setForegroundNotificationPresentationOptions(
          alert: true, badge: true, sound: true);
      await foregroundNotificationHandler();
      await terminatedStateNotificationHandler();

      FirebaseMessaging.onMessageOpenedApp.listen((remoteMessage) {
        _handleNotificationNavigation(remoteMessage);
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint("ERROR IS ${e.toString()}");
      }
    }
  }

  Future disposeListeners() async {
    try {
      await onMessageOpen?.cancel();
      await foregroundStream?.cancel();
    } catch (e) {
      if (kDebugMode) {
        debugPrint("ERROR IS ${e.toString()}");
      }
    }
  }
}
