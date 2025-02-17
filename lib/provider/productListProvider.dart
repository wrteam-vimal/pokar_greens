import 'package:project/helper/utils/generalImports.dart';

enum ProductState {
  initial,
  loaded,
  loading,
  loadingMore,
  empty,
  error,
}

class ProductListProvider extends ChangeNotifier {
  ProductState productState = ProductState.initial;
  String message = '';
  int currentSortByOrderIndex = 0;
  late ProductList productList;
  List<ProductListItem> products = [];
  bool hasMoreData = false;
  int totalData = 0;
  int offset = 0;

  getProductListProvider(
      {required Map<String, dynamic> params,
      required BuildContext context}) async {
    if (offset == 0) {
      productState = ProductState.loading;
    } else {
      productState = ProductState.loadingMore;
    }
    notifyListeners();

    params[ApiAndParams.limit] = Constant.defaultDataLoadLimitAtOnce.toString();
    params[ApiAndParams.offset] = offset.toString();

    try {
      Map<String, dynamic> response =
          await getProductListApi(context: context, params: params);
      if (response[ApiAndParams.status].toString() == "1") {
        productList = ProductList.fromJson(response);

        totalData = int.parse(productList.total);

        if (totalData > 0) {
          products.addAll(productList.data);

          hasMoreData = totalData > products.length;

          if (hasMoreData) {
            offset += Constant.defaultDataLoadLimitAtOnce;
          }
          productState = ProductState.loaded;
          notifyListeners();
        } else {
          productState = ProductState.empty;
          notifyListeners();
        }
      } else {
        message = Constant.somethingWentWrong;
        productState = ProductState.empty;
        notifyListeners();
      }
    } catch (e) {
      message = e.toString();
      showMessage(context, message, MessageType.error);
      productState = ProductState.error;
      notifyListeners();
    }
  }
}
