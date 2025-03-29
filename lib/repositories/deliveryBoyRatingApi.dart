import 'package:project/helper/utils/generalImports.dart';

Future addDeliveryBoyRating({
  required BuildContext context,
  required Map<String, String> params,
}) async {
  try {
    var response = await sendApiRequest(
        apiName: ApiAndParams.apiRateDeliveryBoy,
        params: params,
        context: context,
        isPost: true);
    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}
