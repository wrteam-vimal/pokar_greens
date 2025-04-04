import 'package:project/helper/utils/generalImports.dart';

Future getComplaintsList(
    {required BuildContext context,
    required Map<String, String> params}) async {
  try {
    var response = await sendApiRequest(
        apiName: ApiAndParams.apiComplaints,
        params: params,
        isPost: false,
        context: context);
    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}

Future addComplaints(
    {required BuildContext context,
    required Map<String, String> params,
    required List<String> fileParamsNames,
    required List<String> fileParamsFilesPath}) async {
  try {
    var response = await sendApiMultiPartRequest(
        apiName: ApiAndParams.apiComplaints,
        params: params,
        fileParamsFilesPath: fileParamsFilesPath,
        fileParamsNames: fileParamsNames,
        context: context);
    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}

Future getComplaint({
  required BuildContext context,
  required Map<String, String> params,
}) async {
  try {
    var response = await sendApiRequest(
        apiName: ApiAndParams.apiGetComplaints,
        params: params,
        isPost: false,
        context: context);
    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}
