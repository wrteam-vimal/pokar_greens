import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/ratingImages.dart';
import 'package:project/repositories/ratingsAndReview.dart';

enum DeliveryBoyRatingAddState {
  initial,
  loading,
  loaded,
  loadingMore,
  empty,
  error,
}

class DeliveryBoyRatingProvider extends ChangeNotifier {
  DeliveryBoyRatingAddState deliveryBoyRatingAddState =
      DeliveryBoyRatingAddState.initial;
  String message = '';
  late ProductRatingData productRatingData;
  bool hasMoreData = false;

  Future addRating({
    required BuildContext context,
    required Map<String, String> params,
  }) async {
    deliveryBoyRatingAddState = DeliveryBoyRatingAddState.loading;
    notifyListeners();

    try {
      Map<String, dynamic> ratingData = await addDeliveryBoyRating(
        context: context,
        params: params,
      );

      if (ratingData[ApiAndParams.success] == true) {
        deliveryBoyRatingAddState = DeliveryBoyRatingAddState.loaded;
        notifyListeners();

        showMessage(
            context,
            getTranslatedValue(context, "rating_added_successfully"),
            MessageType.success);

      } else {
        message = ratingData[ApiAndParams.message];
        showMessage(context, message, MessageType.warning);
        deliveryBoyRatingAddState = DeliveryBoyRatingAddState.empty;
        notifyListeners();
        return null;
      }
    } catch (e) {
      message = e.toString();
      showMessage(context, message, MessageType.warning);
      deliveryBoyRatingAddState = DeliveryBoyRatingAddState.error;
      notifyListeners();
      rethrow;
    }
  }
}
