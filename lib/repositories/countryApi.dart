import 'package:project/helper/utils/generalImports.dart';

Future getCountryApi(
    {required BuildContext context,
    required Map<String, String> params}) async {
  try {
    var response = await sendApiRequest(
        apiName: ApiAndParams.apiCountries,
        params: params,
        isPost: false,
        context: context);
    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}
