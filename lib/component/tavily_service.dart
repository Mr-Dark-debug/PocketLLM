import 'dart:convert';
import 'package:http/http.dart' as http;

class TavilyService {
  final String _apiKey = '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'; // Replace with your actual Tavily API key
  final String _baseUrl = 'https://api.tavily.com/search';

  Future<Map<String, dynamic>> search(String query) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'query': query,
          'include_answer': true,
          'max_results': 5,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch data from Tavily API');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}