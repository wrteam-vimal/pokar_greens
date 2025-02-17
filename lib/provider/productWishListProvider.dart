import 'package:project/helper/utils/generalImports.dart';

enum ProductAddRemoveFavoriteState {
  initial,
  loading,
  loaded,
  error,
}

class ProductAddOrRemoveFavoriteProvider extends ChangeNotifier {
  ProductAddRemoveFavoriteState productAddRemoveFavoriteState =
      ProductAddRemoveFavoriteState.initial;
  String message = '';
  late int stateId;

  Future<bool> getProductAddOrRemoveFavorite({
    required BuildContext context,
    required Map<String, dynamic> params,
    required int productId,
  }) async {
    try {
      bool returnState = false;
      stateId = productId;
      productAddRemoveFavoriteState = ProductAddRemoveFavoriteState.loading;
      notifyListeners();

      Map<String, dynamic> map = await addOrRemoveFavoriteApi(
          context: context,
          params: params,
          isAdd: !Constant.favorite.contains(productId));

      if (map[ApiAndParams.status].toString() == "1") {
        productAddRemoveFavoriteState = ProductAddRemoveFavoriteState.loaded;
        notifyListeners();
        returnState = true;
        if (Constant.favorite.contains(productId)) {
          Constant.favorite.remove(productId);
        } else {
          Constant.favorite.add(productId);
        }
        if ((await Vibration.hasVibrator())) {
          Vibration.vibrate(duration: 100);
        }
      } else {
        message = Constant.somethingWentWrong;
        productAddRemoveFavoriteState = ProductAddRemoveFavoriteState.error;
        notifyListeners();
        returnState = false;
      }
      return returnState;
    } catch (e) {
      rethrow;
    }
  }
}

enum ProductWishListState {
  initial,
  loading,
  loaded,
  loadingMore,
  error,
}

class ProductWishListProvider extends ChangeNotifier {
  ProductWishListState productWishListState = ProductWishListState.initial;
  String message = '';
  List<ProductListItem> wishlistProducts = [];
  bool hasMoreData = false;
  int totalData = 0;
  int offset = 0;

  getProductWishListProvider({
    required Map<String, dynamic> params,
    required BuildContext context,
  }) async {
    if (offset == 0) {
      productWishListState = ProductWishListState.loading;
    } else {
      productWishListState = ProductWishListState.loadingMore;
    }
    notifyListeners();

    try {
      params[ApiAndParams.limit] =
          Constant.defaultDataLoadLimitAtOnce.toString();
      params[ApiAndParams.offset] = offset.toString();

      Map<String, dynamic> getData =
          (await getProductWishListApi(context: context, params: params));

      if (getData[ApiAndParams.status].toString() == "1") {
        totalData = int.parse(getData[ApiAndParams.total].toString());
        List<ProductListItem> tempProductWishLists = (getData['data'] as List)
            .map((e) => ProductListItem.fromJson(Map.from(e)))
            .toList();

        wishlistProducts.addAll(tempProductWishLists);
        hasMoreData = totalData > wishlistProducts.length;
        if (hasMoreData) {
          offset += Constant.defaultDataLoadLimitAtOnce;
        }

        productWishListState = ProductWishListState.loaded;

        notifyListeners();
      } else {
        productWishListState = ProductWishListState.error;
        notifyListeners();
      }
    } catch (e) {
      message = e.toString();
      productWishListState = ProductWishListState.error;
      notifyListeners();
    }
  }

  changeCurrentState(ProductWishListState state) {
    productWishListState = state;
  }

  addRemoveFavoriteProduct(ProductListItem? product) {
    if (product != null) {
      if (wishlistProducts.contains(product)) {
        wishlistProducts.remove(product);
      } else {
        wishlistProducts.add(product);
      }

      if (wishlistProducts.isEmpty) {
        changeCurrentState(ProductWishListState.error);
      } else {
        changeCurrentState(ProductWishListState.loaded);
      }

      notifyListeners();
    }
  }
}
