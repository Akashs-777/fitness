import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl =
      'https://3000-idx-fitness-api-1741999933652.cluster-pb4ljhlmg5hqsxnzpc56r3prxw.cloudworkstations.dev/';

  //Handle API response
  static dynamic _processResponse(http.Response response) {
    return response;
    // if (response.statusCode >= 200 && response.statusCode < 300) {
    //   return response.body;
    // } else {
    //   return {
    //     "error": "Request failed",
    //     "statusCode": response.statusCode,
    //     "body": response.body,
    //   };
    // }
  }

  //Generic GET request
  static Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));
      return _processResponse(response);
    } catch (e) {
      return {"error": "Failed to connect to the server: $e"};
    }
  }

  //Generic POST request
  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } catch (e) {
      return {"error": "Failed to connect to the server: $e"};
    }
  }

  //Generic PUT request
  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    // Suggested code may be subject to a license. Learn more: ~LicenseLog:1372389514.
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } catch (e) {
      return {"error": "Failed to connect to the server: $e"};
    }
  }

  //Generic DELETE request
  static Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl$endpoint'));
      return _processResponse(response);
    } catch (e) {
      return {"error": "Failed to connect to the server: $e"};
    }
  }
}
