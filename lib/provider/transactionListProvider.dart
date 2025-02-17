import 'package:project/helper/utils/generalImports.dart';

enum TransactionState {
  initial,
  loading,
  loaded,
  loadingMore,
  empty,
  error,
}

class TransactionProvider extends ChangeNotifier {
  TransactionState itemsState = TransactionState.initial;
  String message = '';
  late Transaction transactionData;
  List<TransactionData> transactions = [];
  bool hasMoreData = false;
  int totalData = 0;
  int offset = 0;

  getTransactionProvider({
    required Map<String, dynamic> params,
    required BuildContext context,
  }) async {
    if (offset == 0) {
      itemsState = TransactionState.loading;
    } else {
      itemsState = TransactionState.loadingMore;
    }
    notifyListeners();

    try {
      params[ApiAndParams.limit] =
          Constant.defaultDataLoadLimitAtOnce.toString();
      params[ApiAndParams.offset] = offset.toString();

      Map<String, dynamic> getData =
          (await getTransactionApi(context: context, params: params));

      if (getData[ApiAndParams.status].toString() == "1") {
        totalData = int.parse(getData[ApiAndParams.total].toString());
        List<TransactionData> tempTransactions = (getData['data'] as List)
            .map((e) => TransactionData.fromJson(Map.from(e)))
            .toList();

        transactions.addAll(tempTransactions);

        hasMoreData = totalData > transactions.length;
        if (hasMoreData) {
          offset += Constant.defaultDataLoadLimitAtOnce;
        }

        if (totalData > 0) {
          itemsState = TransactionState.loaded;
          notifyListeners();
        } else {
          itemsState = TransactionState.empty;
          notifyListeners();
        }
      } else {
        itemsState = TransactionState.empty;
        notifyListeners();
      }
    } catch (e) {
      message = e.toString();
      itemsState = TransactionState.error;
      showMessage(
        context,
        message,
        MessageType.warning,
      );
      notifyListeners();
    }
  }
}
