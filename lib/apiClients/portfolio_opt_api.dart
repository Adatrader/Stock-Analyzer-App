import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:stock_analyzer/model/api_response.dart';

class PortfolioOptApi {
  late Map<String, String> header;
  final String apiUser = dotenv.get('PORTFOLIO_OPT_USER', fallback: '');
  final String apiPass = dotenv.get('PORTFOLIO_OPT_PASS', fallback: '');
  late String base = '';

  PortfolioOptApi() {
    header = {};
    header.addAll({'Content-Type': 'application/json'});
    header.addAll({'Access-Control-Allow-Origin': '*'});
    base =
        'https://$apiUser:$apiPass@portfolio-optimization-api.herokuapp.com/api/v1';
  }

  Future<ApiResponseBody> post(
      String endpoint, String params, dynamic body) async {
    var apiClient = http.Client();
    var response = await apiClient.post(Uri.parse(base + endpoint + params),
        headers: header, body: jsonEncode(body));
    return ApiResponseBody(
        response.statusCode, json.decode(response.body), response);
  }
}
