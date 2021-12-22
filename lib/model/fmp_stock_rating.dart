class FmpStockRating {
  String symbol;
  String date;
  String rating;
  int ratingScore;
  String ratingRecommendation;
  int dcfScore;
  String dcfRecommendation;
  int roeScore;
  String roeRecommendation;
  int roaScore;
  String roaRecommendation;
  int deScore;
  String deRecommendation;
  int peScore;
  String peRecommendation;
  int pbScore;
  String pbRecommendation;

  FmpStockRating(
      this.symbol,
      this.date,
      this.rating,
      this.ratingScore,
      this.ratingRecommendation,
      this.dcfScore,
      this.dcfRecommendation,
      this.roeScore,
      this.roeRecommendation,
      this.roaScore,
      this.roaRecommendation,
      this.deScore,
      this.deRecommendation,
      this.peScore,
      this.peRecommendation,
      this.pbScore,
      this.pbRecommendation);

  factory FmpStockRating.fromJson(Map<String, dynamic> json) => FmpStockRating(
        json["symbol"] ?? "",
        json["date"] ?? "",
        json["rating"] ?? "",
        json["ratingScore"].toInt(),
        json["ratingRecommendation"] ?? "",
        json["ratingDetailsDCFScore"].toInt(),
        json["ratingDetailsDCFRecommendation"] ?? "",
        json["ratingDetailsROEScore"].toInt(),
        json["ratingDetailsROERecommendation"] ?? "",
        json["ratingDetailsROAScore"].toInt(),
        json["ratingDetailsROARecommendation"] ?? "",
        json["ratingDetailsDEScore"].toInt(),
        json["ratingDetailsDERecommendation"] ?? "",
        json["ratingDetailsPEScore"].toInt(),
        json["ratingDetailsPERecommendation"] ?? "",
        json["ratingDetailsPBScore"].toInt(),
        json["ratingDetailsPBRecommendation"] ?? "",
      );
}
