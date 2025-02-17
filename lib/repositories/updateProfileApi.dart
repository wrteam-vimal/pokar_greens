import 'package:project/helper/utils/generalImports.dart';

Future<Map<String, dynamic>> getUpdateProfileApi(
    {required String apiName,
    required Map<String, String> params,
    required List<String> fileParamsNames,
    required List<String> fileParamsFilesPath,
    required BuildContext context}) async {
  var response = await sendApiMultiPartRequest(
      apiName: apiName,
      params: params,
      fileParamsNames: fileParamsNames,
      fileParamsFilesPath: fileParamsFilesPath,
      context: context);

  return json.decode(response);
}
