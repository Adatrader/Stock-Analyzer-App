import 'package:stock_analyzer/apiClients/portfolio_opt_api.dart';
import 'package:stock_analyzer/model/portfolio_opt_results.dart';

class PortfolioOptHelper {
  String sharpeEndpoint = '/max_sharpe';
  String volatilityEndpoint = '/efficient_risk';
  String returnEndpoint = '/target_return';
  String customEtfEndpoint = '/custom_etf_max_sharpe';
  late PortfolioOptApi portOptApi;

  PortfolioOptHelper() {
    portOptApi = PortfolioOptApi();
  }

  Future<PortfolioOptResults?> getMaxSharpe(
      List<String> tickers, String investment) async {
    var response = await portOptApi.post(
        sharpeEndpoint, "?investment=" + investment, {"tickers": tickers});
    // print(response.Body);
    if (isValid(response.statusCode)) {
      var bodyResponse = response.Body;
      if (bodyResponse.isNotEmpty) {
        return PortfolioOptResults.fromJson(bodyResponse);
      }
    }
    return null;
  }

  Future<PortfolioOptResults?> getCustomEtfMaxSharpe(String investment) async {
    var response = await portOptApi
        .post(customEtfEndpoint, "?investment=" + investment, {});
    // print(response.Body);
    if (isValid(response.statusCode)) {
      var bodyResponse = response.Body;
      if (bodyResponse.isNotEmpty) {
        return PortfolioOptResults.fromJson(bodyResponse);
      }
    }
    return null;
  }

  Future<PortfolioOptResults?> getOptimizedVolatility(
      List<String> tickers, String investment, String maxVolatlity) async {
    var response = await portOptApi.post(
        volatilityEndpoint,
        "?investment=" + investment + "&max_volatility=" + maxVolatlity,
        {"tickers": tickers});
    if (isValid(response.statusCode)) {
      var bodyResponse = response.Body;
      if (bodyResponse.isNotEmpty) {
        return PortfolioOptResults.fromJson(bodyResponse);
      }
    }
    return null;
  }

  Future<PortfolioOptResults?> getTargetReturn(
      List<String> tickers, String investment, String returnTarget) async {
    var response = await portOptApi.post(
        returnEndpoint,
        "?investment=" + investment + "&return=" + returnTarget,
        {"tickers": tickers});
    if (isValid(response.statusCode)) {
      var bodyResponse = response.Body;
      if (bodyResponse.isNotEmpty) {
        return PortfolioOptResults.fromJson(bodyResponse);
      }
    }
    return null;
  }

  static bool isValid(int responseCode) {
    if (responseCode != 200 && responseCode != 201) {
      return false;
    }
    return true;
  }
}
