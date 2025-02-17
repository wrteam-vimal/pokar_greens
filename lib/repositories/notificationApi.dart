import 'package:project/helper/utils/generalImports.dart';

Future<Map<String, dynamic>> getNotificationApi(
    {required BuildContext context,
    required Map<String, dynamic> params}) async {
  var response = await sendApiRequest(
      apiName: ApiAndParams.apiNotification,
      params: params,
      isPost: false,
      context: context);

  return json.decode(response);
}
