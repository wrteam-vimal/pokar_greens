import 'package:project/helper/utils/generalImports.dart';

Future<Map<String, dynamic>> getUserDetail(
    {required BuildContext context}) async {
  var response = await sendApiRequest(
    apiName: ApiAndParams.apiUserDetails,
    params: {},
    isPost: false,
    context: context,
  );

  return json.decode(response);
}
