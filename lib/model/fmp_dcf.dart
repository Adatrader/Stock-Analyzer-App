class FmpDcf {
  String symbol;
  String date;
  double dcf;
  double stockPrice;

  FmpDcf(this.symbol, this.date, this.dcf, this.stockPrice);

  factory FmpDcf.fromJson(Map<String, dynamic> json) => FmpDcf(
      json["symbol"] ?? "",
      json["name"] ?? "",
      json["dcf"] != null ? json["dcf"].toDouble() : 0,
      json["Stock Price"] != null ? json["Stock Price"].toDouble() : 0);
}
