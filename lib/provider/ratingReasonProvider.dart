import 'package:project/helper/utils/generalImports.dart';

enum RatingReasonState {
  initial,
  loading,
  silentLoading,
  loaded,
  error,
}

class RatingReasonProvider extends ChangeNotifier {
  RatingReasonState ratingReasonState = RatingReasonState.initial;
  RatingReasonList? ratingReasonList;
  String message = '';

  Future getRatingReason(
      {required Map<String, String> params,
      required BuildContext context}) async {
    if (ratingReasonState == RatingReasonState.loaded) {
      ratingReasonState = RatingReasonState.silentLoading;
      notifyListeners();
    } else {
      ratingReasonState = RatingReasonState.loading;
      notifyListeners();
    }

    try {
      Map<String, dynamic> getRatingReason =
          await fetchRatingReason(context: context, params: params);

      if (getRatingReason[ApiAndParams.success].toString() == "true") {
        ratingReasonList = RatingReasonList.fromJson(getRatingReason);
        ratingReasonState = RatingReasonState.loaded;
        notifyListeners();
        return ratingReasonList;
      }

      /* if (getRatingReason[ApiAndParams.success].toString() == "true") {
        ratingReasonState = RatingReasonState.loaded;
        notifyListeners();
        return RatingReasonList.fromJson(getRatingReason[ApiAndParams.data][0]);
      }*/
      else {
        showMessage(
            context, getRatingReason[message].toString(), MessageType.warning);
        ratingReasonState = RatingReasonState.loaded;
        notifyListeners();
        return null;
      }
    } catch (e) {
      message = e.toString();
      ratingReasonState = RatingReasonState.error;
      showMessage(
        context,
        message,
        MessageType.warning,
      );
      notifyListeners();
      return null;
    }
  }
}
