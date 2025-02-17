import 'package:project/helper/utils/generalImports.dart';

enum PreviousOrdersState {
  initial,
  loading,
  loaded,
  loadingMore,
  empty,
  error,
}

class PreviousOrdersProvider extends ChangeNotifier {
  PreviousOrdersState previousOrdersState = PreviousOrdersState.initial;
  String message = '';
  List<Order> orders = [];
  bool hasMoreData = false;
  int totalData = 0;
  int offset = 0;

  void updateOrder(Order order) {
    final orderIndex = orders.indexWhere((element) {
      element.id == order.id;
      return element.id == order.id;
    });

    if (orderIndex != -1) {
      orders[orderIndex] = order;
    }
    notifyListeners();
  }

  getOrders({
    required Map<String, String> params,
    required BuildContext context,
  }) async {
    if (offset == 0) {
      previousOrdersState = PreviousOrdersState.loading;
    } else {
      previousOrdersState = PreviousOrdersState.loadingMore;
    }
    notifyListeners();

    try {
      params[ApiAndParams.limit] =
          Constant.defaultDataLoadLimitAtOnce.toString();
      params[ApiAndParams.offset] = offset.toString();

      Map<String, dynamic> getData =
          (await fetchOrders(context: context, params: params));

      if (getData[ApiAndParams.status].toString() == "1") {
        totalData = int.parse(getData[ApiAndParams.total].toString());
        List<Order> tempOrders = (getData['data'] as List)
            .map((e) => Order.fromJson(Map.from(e ?? {})))
            .toList();

        orders.addAll(tempOrders);

        hasMoreData = totalData > orders.length;
        if (hasMoreData) {
          offset += Constant.defaultDataLoadLimitAtOnce;
        }

        previousOrdersState = PreviousOrdersState.loaded;
        notifyListeners();
      } else {
        previousOrdersState = PreviousOrdersState.empty;
        notifyListeners();
      }
    } catch (e) {
      message = e.toString();
      previousOrdersState = PreviousOrdersState.error;
      showMessage(
        context,
        message,
        MessageType.warning,
      );
      notifyListeners();
    }
  }
}
