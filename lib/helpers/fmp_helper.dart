import 'package:stock_analyzer/apiClients/fmp_api.dart';
import 'package:stock_analyzer/constants/crossover.dart';
import 'package:stock_analyzer/model/ema_stock.dart';
import 'package:stock_analyzer/model/fmp_dcf.dart';
import 'package:stock_analyzer/model/fmp_stock.dart';
import 'package:stock_analyzer/model/fmp_stock_rating.dart';
import 'package:stock_analyzer/model/stock_item.dart';

class StockFmpHelper {
  String baseUrl =
      'https://financialmodelingprep.com/api/v3/technical_indicator/daily/';
  late FmpApi fmpApi;

  // Constructor
  StockFmpHelper() {
    fmpApi = FmpApi();
  }

  Future<Map<String, double>> getEmaList(String ticker, int period) async {
    Map<String, double> emaMap = {};
    var response = await fmpApi
        .get(baseUrl + ticker + "?period=" + period.toString() + "&type=ema");
    if (isValid(response.statusCode)) {
      var data = response.Data;
      for (var elem in data) {
        emaMap[elem['date']] = elem['ema'];
      }
    }
    return emaMap;
  }

  Future<String> getCrossover(String ticker) async {
    List<EmaStock> fiveList = [];
    List<EmaStock> thirteenList = [];
    // FIXME: Temp fix for fmp server error
    try {
      // Get 5
      var firstResponse =
          await fmpApi.get(baseUrl + ticker + "?period=5&type=ema");
      if (isValid(firstResponse.statusCode)) {
        for (var stock in firstResponse.Data) {
          if (fiveList.length == 2) {
            break;
          }
          fiveList.add(EmaStock.fromJson(stock));
        }
      }
      // Get 13
      var secondResponse =
          await fmpApi.get(baseUrl + ticker + "?period=13&type=ema");
      if (isValid(secondResponse.statusCode)) {
        for (var stock in secondResponse.Data) {
          if (thirteenList.length == 2) {
            break;
          }
          thirteenList.add(EmaStock.fromJson(stock));
        }
      }
      // Calculate
      if (fiveList.length == 2 && thirteenList.length == 2) {
        // Crossed above
        if (fiveList[1].ema < thirteenList[1].ema &&
            fiveList[0].ema > thirteenList[0].ema) {
          return Crossover.CROSSOVER_UP;
          // Crossed below
        } else if (fiveList[1].ema > thirteenList[1].ema &&
            fiveList[0].ema < thirteenList[0].ema) {
          return Crossover.CROSSOVER_DOWN;
        }
      }
    } catch (e) {
      return Crossover.NEUTRAL;
    }
    return Crossover.NEUTRAL;
  }

  Future<List<FmpStock>> getSearchResult(String query) async {
    List<FmpStock> suggestions = [];
    var response = await fmpApi.get(
        'https://financialmodelingprep.com/api/v3/search?query=$query&limit=10');
    if (isValid(response.statusCode)) {
      for (var stock in response.Data) {
        suggestions.add(FmpStock.fromJson(stock));
      }
    }
    return suggestions;
  }

  Future<FmpDcf?> getStockDcf(String ticker) async {
    var response = await fmpApi.getEnd(
        'https://financialmodelingprep.com/api/v3/discounted-cash-flow/$ticker');
    if (isValid(response.statusCode)) {
      for (var stock in response.Data) {
        // print(stock);
        return FmpDcf.fromJson(stock);
      }
    }
    return null;
  }

  Future<FmpStockRating?> getStockRating(String ticker) async {
    var response = await fmpApi
        .getEnd('https://financialmodelingprep.com/api/v3/rating/$ticker');
    if (isValid(response.statusCode)) {
      for (var stock in response.Data) {
        // print(stock);
        return FmpStockRating.fromJson(stock);
      }
    }
    return null;
  }

  double percentageDifference(double currentPrice, double dcf) {
    return ((dcf - currentPrice) / currentPrice) * 100;
  }

  Future<List<List<dynamic>>> getStocksFundamental(
      List<StockItem> stocks) async {
    List<List<dynamic>> result = [];
    for (StockItem stock in stocks) {
      FmpDcf? dcf = await getStockDcf(stock.ticker);
      FmpStockRating? rating = await getStockRating(stock.ticker);
      List<dynamic> list = [];
      if (dcf != null && rating != null && dcf.dcf != 0) {
        list.add(dcf);
        list.add(rating);
        // Add percentage difference
        list.add(percentageDifference(dcf.stockPrice, dcf.dcf));
        result.add(list);
      }
    }
    result.sort((listOne, listTwo) => listTwo[2].compareTo(listOne[2]));
    return result;
  }

  static bool isValid(int responseCode) {
    if (responseCode != 200 && responseCode != 201) {
      return false;
    }
    return true;
  }
}
