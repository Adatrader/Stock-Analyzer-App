import 'package:stock_analyzer/model/stock_item.dart';

class StockList {
  List<StockItem> items = [];

  toJSONEncodable() {
    return items.map((item) {
      return item.toJSONEncodable();
    }).toList();
  }
}
