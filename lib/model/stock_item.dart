class StockItem {
  String ticker;
  String companyName;

  StockItem({required this.ticker, required this.companyName});

  toJSONEncodable() {
    Map<String, dynamic> map = {};

    map['ticker'] = ticker;
    map['company_name'] = companyName;

    return map;
  }
}
