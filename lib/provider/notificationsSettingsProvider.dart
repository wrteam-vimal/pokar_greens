import 'package:project/helper/utils/generalImports.dart';

enum NotificationsSettingsState { initial, loading, loaded, error }

enum NotificationsSettingsUpdateState { initial, loading, loaded }

class NotificationsSettingsProvider extends ChangeNotifier {
  NotificationsSettingsState notificationsSettingsState =
      NotificationsSettingsState.initial;

  NotificationsSettingsUpdateState notificationsSettingsUpdateState =
      NotificationsSettingsUpdateState.initial;

  late AppNotificationSettings notificationSettings;
  late List<AppNotificationSettingsData> notificationSettingsDataList;
  List<int> mailSettings = [];
  List<int> mobileSettings = [];
  List<int> smsSettings = [];

  Future getAppNotificationSettingsApiProvider(
      {required Map<String, String> params,
      required BuildContext context}) async {
    try {
      notificationsSettingsState = NotificationsSettingsState.loading;
      notifyListeners();

      Map<String, dynamic> notificationSettingsApiResponse =
          await getAppNotificationSettingsRepository(
              params: params, context: context);

      if (notificationSettingsApiResponse[ApiAndParams.status].toString() ==
          "1") {
        notificationSettings =
            AppNotificationSettings.fromJson(notificationSettingsApiResponse);

        notificationSettingsDataList = notificationSettings.data ?? [];

        for (int i = 0; i < notificationSettingsDataList.length; i++) {
          mailSettings.add(
              int.parse(notificationSettingsDataList[i].mailStatus ?? "0"));
          mobileSettings.add(
              int.parse(notificationSettingsDataList[i].mobileStatus ?? "0"));
          smsSettings
              .add(int.parse(notificationSettingsDataList[i].smsStatus ?? "0"));
        }

        notificationsSettingsState = NotificationsSettingsState.loaded;
        notifyListeners();
      } else {
        showMessage(
          context,
          getTranslatedValue(context, "settings_saved_successfully"),
          MessageType.success,
        );
        notificationsSettingsState = NotificationsSettingsState.error;
        notifyListeners();
      }
    } catch (e) {
      showMessage(
        context,
        e.toString(),
        MessageType.warning,
      );
      notificationsSettingsState = NotificationsSettingsState.error;
      notifyListeners();
    }
  }

  Future updateAppNotificationSettingsApiProvider(
      {required BuildContext context}) async {
    try {
      notificationsSettingsUpdateState =
          NotificationsSettingsUpdateState.loading;
      notifyListeners();

      String statusIdsList = "";
      String mailStatusesList = "";
      String mobileStatusesList = "";
      String smsStatusesList = "";

      for (int i = 0; i < notificationSettingsDataList.length; i++) {
        AppNotificationSettingsData notificationsSettingsData =
            notificationSettingsDataList[i];

        if (i < (notificationSettingsDataList.length - 1)) {
          statusIdsList =
              "$statusIdsList${notificationsSettingsData.orderStatusId.toString()},";
          mailStatusesList = "$mailStatusesList${mailSettings[i].toString()},";
          mobileStatusesList =
              "$mobileStatusesList${mobileSettings[i].toString()},";
          smsStatusesList = "$mobileStatusesList${smsSettings[i].toString()},";
        } else {
          statusIdsList =
              "$statusIdsList${notificationsSettingsData.orderStatusId.toString()}";
          mailStatusesList = "$mailStatusesList${mailSettings[i].toString()}";
          mobileStatusesList =
              "$mobileStatusesList${mobileSettings[i].toString()}";
          smsStatusesList = "$mobileStatusesList${smsSettings[i].toString()}";
        }
      }

      Map<String, String> params = {};
      params[ApiAndParams.statusIds] = statusIdsList;
      params[ApiAndParams.mobileStatuses] = mobileStatusesList;
      params[ApiAndParams.mailStatuses] = mailStatusesList;
      params[ApiAndParams.smsStatuses] = smsStatusesList;

      Map<String, dynamic> notificationSettingsUpdateApiResponse =
          await updateAppNotificationSettingsRepository(
              params: params, context: context);

      showMessage(
        context,
        notificationSettingsUpdateApiResponse[ApiAndParams.message],
        MessageType.success,
      );
      notificationsSettingsUpdateState =
          NotificationsSettingsUpdateState.loaded;
      notifyListeners();
    } catch (e) {
      showMessage(
        context,
        e.toString(),
        MessageType.warning,
      );
      notificationsSettingsUpdateState =
          NotificationsSettingsUpdateState.loaded;
      notifyListeners();
    }
  }

  changeMailSetting({required int index, required int status}) {
    mailSettings[index] = status;
    notifyListeners();
  }

  changeMobileSetting({required int index, required int status}) {
    mobileSettings[index] = status;
    notifyListeners();
  }

  changeSMSSetting({required int index, required int status}) {
    smsSettings[index] = status;
    notifyListeners();
  }
}
