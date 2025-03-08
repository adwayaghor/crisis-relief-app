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

  static Future<String> getCrisisImageUrl(String crisisTitle) async {
  final prompt = """
    Provide a single URL to a royalty-free, high-quality image that represents a "$crisisTitle" crisis.
    The image should be appropriate for a donation app.
    Only return a valid image URL with no additional text or explanation.
    Example: https://example.com/image.jpg
  """;
  
  try {
    final imageUrl = await generateText(prompt);
    return imageUrl.trim();
  } catch (e) {
    print("❌ Error getting crisis image: $e");
    // Return a default image if there's an error
    return "https://educationpost.in/_next/image?url=https%3A%2F%2Fapi.educationpost.in%2Fs3-images%2F1736253267338-untitled%20(39).jpg&w=1920&q=75";
  }
}
}
