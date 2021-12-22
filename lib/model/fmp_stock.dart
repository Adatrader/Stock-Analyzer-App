class FmpStock {
  String symbol;
  String name;

  FmpStock(this.symbol, this.name);

  factory FmpStock.fromJson(Map<String, dynamic> json) => FmpStock(
        json["symbol"],
        json["name"] ?? "",
      );
}
