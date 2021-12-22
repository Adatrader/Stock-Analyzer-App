import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:stock_analyzer/model/api_response.dart';

class FmpApi {
  late Map<String, String> header;
  final String apiKey = dotenv.get('FMP_KEY', fallback: '');

  FmpApi() {
    header = {};
    header.addAll({'Content-Type': 'application/json'});
    header.addAll({'Access-Control-Allow-Origin': '*'});
  }

  Future<ApiResponseData> get(String url) async {
    var apiClient = http.Client();
    var response = await apiClient.get(Uri.parse(url + '&apikey=' + apiKey),
        headers: header);
    return ApiResponseData(
        response.statusCode, json.decode(response.body), response);
  }

  Future<ApiResponseData> getEnd(String url) async {
    var apiClient = http.Client();
    var response = await apiClient.get(Uri.parse(url + '?apikey=' + apiKey),
        headers: header);
    return ApiResponseData(
        response.statusCode, json.decode(response.body), response);
  }
}
