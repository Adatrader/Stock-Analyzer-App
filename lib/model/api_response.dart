import 'package:http/http.dart';

class ApiResponseBody {
  final int statusCode;
  final Map<String, dynamic> body;
  final Response initialResponse;

  const ApiResponseBody(this.statusCode, this.body, this.initialResponse);

  int get StatusCode => statusCode;
  Map<String, dynamic> get Body => body;
  Response get OrignalResponse => initialResponse;
}

class ApiResponseData {
  final int statusCode;
  final List<dynamic> data;
  final Response initialResponse;

  const ApiResponseData(this.statusCode, this.data, this.initialResponse);

  int get StatusCode => statusCode;
  List<dynamic> get Data => data;
  Response get OrignalResponse => initialResponse;
}
