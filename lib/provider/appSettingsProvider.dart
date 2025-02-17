import 'package:project/helper/utils/generalImports.dart';

enum SettingsState { initial, loading, loaded, error }

class AppSettingsProvider extends ChangeNotifier {
  SettingsState settingsState = SettingsState.initial;
  String message = "";

  Future getAppSettingsProvider(BuildContext context) async {
    settingsState = SettingsState.loading;
    notifyListeners();
    try {
      Map<String, dynamic> settingsData =
      await getAppSettings(context: context);
      if (settingsData[ApiAndParams.status].toString() == "1") {
        SettingsData settings =
        SettingsData.fromJson(settingsData[ApiAndParams.data]);

        Constant.favorite = settings.favoriteProductIds?.cast<int>() ?? [];

        Constant.maxAllowItemsInCart = settings.maxCartItemsCount ?? "";
        Constant.minimumOrderAmount = settings.minOrderAmount ?? "";
        Constant.minimumReferEarnOrderAmount =
            settings.minReferEarnOrderAmount ?? "";
        Constant.referEarnBonus = settings.referEarnBonus ?? "";
        Constant.maximumReferEarnAmount = settings.maxReferEarnAmount ?? "";
        Constant.minimumWithdrawalAmount =
            settings.minimumWithdrawalAmount ?? "";
        Constant.maximumProductReturnDays = settings.maxProductReturnDays ?? "";
        Constant.userWalletRefillLimit = settings.userWalletRefillLimit ?? "";
        Constant.isReferEarnOn = settings.isReferEarnOn ?? "";
        Constant.referEarnMethod = settings.referEarnMethod ?? "";
        Constant.privacyPolicy = settings.privacyPolicy ?? "";
        Constant.termsConditions = settings.termsConditions ?? "";
        Constant.aboutUs = settings.aboutUs ?? "";
        Constant.contactUs = settings.contactUs ?? "";
        Constant.returnAndExchangesPolicy =
            settings.returnsAndExchangesPolicy ?? "";
        Constant.cancellationPolicy = settings.cancellationPolicy ?? "";
        Constant.shippingPolicy = settings.shippingPolicy ?? "";
        Constant.googleApiKey = settings.googlePlaceApiKey ?? "";
        Constant.currencyCode = settings.currencyCode.toString().isEmpty ? "USD" : settings.currencyCode.toString();
        Constant.decimalPoints = settings.decimalPoint.toString().isEmpty ? "0" : settings.decimalPoint.toString();
        Constant.currency = settings.currency.toString().isEmpty ? "\$" : settings.currency.toString();
        Constant.appMaintenanceMode = settings.appModeCustomer ?? "0";
        Constant.appMaintenanceModeRemark =
            settings.appModeCustomerRemark ?? "";

        Constant.popupBannerEnabled = settings.popupEnabled == "1";
        Constant.showAlwaysPopupBannerAtHomeScreen =
            settings.popupAlwaysShowHome == "1";
        Constant.popupBannerType = settings.popupType ?? "";
        Constant.popupBannerTypeId = settings.popupTypeId ?? "";
        Constant.popupBannerUrl = settings.popupUrl ?? "";
        Constant.popupBannerImageUrl = settings.popupImage ?? "";
        Constant.playStoreUrl = settings.androidAppUrl ?? "";
        Constant.appStoreUrl = settings.iosAppUrl ?? "";
        Constant.estimateDeliveryDays =
            settings.estimateDeliveryDays?.toInt ?? 0;

        Constant.authTypeAppleLogin = settings.appleLogin ?? "0";
        Constant.authTypeGoogleLogin = settings.googleLogin ?? "0";
        Constant.authTypePhoneLogin = settings.phoneLogin ?? "0";
        Constant.authTypeEmailLogin = settings.emailLogin ?? "0";
        Constant.customSmsGatewayOtpBased =
            settings.customSmsGatewayOtpBased ?? "0";
        Constant.firebaseAuthentication =
            settings.firebaseAuthentication ?? "0";

        if (settings.isVersionSystemOn == "1" &&
            settings.currentVersion.toString().isNotEmpty) {
          Constant.isVersionSystemOn = settings.isVersionSystemOn ?? "";
          Constant.currentRequiredAppVersion = settings.currentVersion ?? "";
          Constant.requiredForceUpdate = settings.requiredForceUpdate ?? "";
          Constant.oneSellerCart = settings.oneSellerCart ?? "0";
          // Constant.guestCartOptionIsOn = settings.guestCart ?? "0";
        }

        if (settings.iosIsVersionSystemOn == "1" &&
            settings.iosCurrentVersion.toString().isNotEmpty) {
          Constant.isIosVersionSystemOn = settings.iosCurrentVersion ?? "";
          Constant.currentRequiredIosAppVersion =
              settings.iosCurrentVersion ?? "";
          Constant.requiredIosForceUpdate =
              settings.iosRequiredForceUpdate ?? "";
        }
        if ((Constant.session.getData(SessionManager.keyLatitude) == "" &&
            Constant.session.getData(SessionManager.keyLongitude) == "") ||
            (Constant.session.getData(SessionManager.keyLatitude) == "0" &&
                Constant.session.getData(SessionManager.keyLongitude) == "0")) {
          String tempLat = settings.defaultCity?.latitude.toString() ?? "0";
          String tempLong = settings.defaultCity?.longitude.toString() ?? "0";
          String tempAddress =
              settings.defaultCity?.formattedAddress.toString() ?? "";

          if (tempAddress == "" ||
              tempLong == "0" ||
              tempLat == "0" ||
              Constant.session.getData(SessionManager.keyLongitude) == "" ||
              Constant.session.getData(SessionManager.keyLatitude) == "" ||
              Constant.session.getData(SessionManager.keyLongitude) == "0" ||
              Constant.session.getData(SessionManager.keyLatitude) == "0" ||
              Constant.session.getData(SessionManager.keyAddress) == "") {
            Constant.session
                .setData(SessionManager.keyLongitude, tempLong, false);
            Constant.session
                .setData(SessionManager.keyLatitude, tempLat, false);
            Constant.session
                .setData(SessionManager.keyAddress, tempAddress, false);
          }

        }

        settingsState = SettingsState.loaded;
        notifyListeners();
      } else {
        message = Constant.somethingWentWrong;
        settingsState = SettingsState.error;
        notifyListeners();
      }
    } catch (e) {
      settingsState = SettingsState.error;
      notifyListeners();
      rethrow;
    }
  }

  changeState() {
    settingsState = SettingsState.error;
    notifyListeners();
  }
}
