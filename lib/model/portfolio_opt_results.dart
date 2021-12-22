class PortfolioOptResults {
  Map<String, dynamic> allocation;
  double annualVolatility;
  String endDate;
  double expectedAnnualReturn;
  double sharpeRatio;
  String startDate;
  Map<String, dynamic> weights;

  PortfolioOptResults(
      this.allocation,
      this.annualVolatility,
      this.endDate,
      this.expectedAnnualReturn,
      this.sharpeRatio,
      this.startDate,
      this.weights);

  factory PortfolioOptResults.fromJson(Map<String, dynamic> json) =>
      PortfolioOptResults(
          json["allocation"],
          json["annual_volitility"],
          json["end_date"],
          json["expected_annual_return"],
          json["sharpe_ratio"],
          json["start_date"],
          json["weights"]);
}
