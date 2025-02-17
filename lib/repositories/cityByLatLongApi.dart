import 'package:project/helper/utils/generalImports.dart';

Future<Map<String, dynamic>> getCityByLatLongApi(
    {required BuildContext context,
    required Map<String, dynamic> params}) async {
  var response = await sendApiRequest(
    apiName: ApiAndParams.apiCity,
    params: params,
    isPost: false,
    context: context,
  );

  return json.decode(response);
}
