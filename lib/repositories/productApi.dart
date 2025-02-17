import 'package:project/helper/utils/generalImports.dart';

Future getProductListApi(
    {required BuildContext context,
    required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
        apiName: ApiAndParams.apiProducts,
        params: params,
        isPost: true,
        context: context);

    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}

Future getProductDetailApi(
    {required BuildContext context,
    required Map<String, dynamic> params}) async {
  try {
    var data = json.decode(await sendApiRequest(
        apiName: ApiAndParams.apiProductDetail,
        params: params,
        isPost: true,
        context: context));

    return data;
  } catch (e) {
    rethrow;
  }
}

Future addOrRemoveFavoriteApi(
    {required BuildContext context,
    required Map<String, dynamic> params,
    required isAdd}) async {
  try {
    var response = await sendApiRequest(
        apiName: isAdd
            ? ApiAndParams.apiAddProductToFavorite
            : ApiAndParams.apiRemoveProductFromFavorite,
        params: params,
        isPost: true,
        context: context);

    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}

Future getProductWishListApi(
    {required BuildContext context,
    required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
        apiName: ApiAndParams.apiFavorite,
        params: params,
        isPost: false,
        context: context);

    return json.decode(response);
  } catch (e) {
    rethrow;
  }
}
