import '../helper/utils/generalImports.dart';

Future<Map<String, dynamic>> fetchRatingReason(
    {required Map<String, String> params,
      required BuildContext context}) async {
  final response = await sendApiRequest(
      apiName: ApiAndParams.apiRatingReasons,
      params: params,
      isPost: false,
      context: context);

  return json.decode(response);
}