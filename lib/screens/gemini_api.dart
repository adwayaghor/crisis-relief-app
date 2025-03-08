import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String apiKey = "AIzaSyC4FPENnIQCRgZuK8hsgQQYR13DXCfll9A"; // Replace with your API key
  static const String model = "gemini-1.5-pro"; // Ensure it's an available model
  static const String apiUrl =
      "https://generativelanguage.googleapis.com/v1/models/$model:generateContent?key=$apiKey";

  static Future<String> generateText(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print("🔹 Gemini API Response: ${response.body}");

        return data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ??
            "❌ No response from Gemini API.";
      } else {
        print("❌ Gemini API Error: ${response.statusCode}");
        print("🔹 Response Body: ${response.body}");
        return "❌ API Error: ${response.statusCode}";
      }
    } catch (e) {
      print("❌ Network or Parsing Error: $e");
      return "❌ Error: $e";
    }
  }
}
