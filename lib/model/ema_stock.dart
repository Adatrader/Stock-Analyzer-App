class EmaStock {
  String date;
  double open;
  double high;
  double low;
  double close;
  double volume;
  double ema;

  EmaStock(this.date, this.open, this.high, this.low, this.close, this.volume,
      this.ema);

  factory EmaStock.fromJson(Map<String, dynamic> json) => EmaStock(
        json["date"],
        json["open"].toDouble(),
        json["high"].toDouble(),
        json["low"].toDouble(),
        json["close"].toDouble(),
        json["volume"].toDouble(),
        json["ema"].toDouble(),
      );
}
