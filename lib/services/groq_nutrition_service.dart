import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:lift_lab/config/secrets.dart';

class GroqNutritionService {
  static const String _apiKey = Secrets.groqApiKey;
  static const String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';


  static Future<Map<String, dynamic>> scanFood(XFile imageFile) async {
    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(imageBytes);

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "meta-llama/llama-4-scout-17b-16e-instruct",
          "messages": [
            {
              "role": "user",
              "content": [
                {
                  "type": "text",
                  "text": "Analyze this image of food. Please provide an estimate of its nutritional content. Your final output must be ONLY a valid, raw JSON object without any additional markdown formatting or text. The JSON object should have exactly these keys: \"food_name\" (string), \"calories\" (int), \"protein\" (int), \"carbs\" (int), and \"fat\" (int)."
                },
                {
                  "type": "image_url",
                  "image_url": {
                    "url": "data:image/jpeg;base64,$base64Image"
                  }
                }
              ]
            }
          ],
          "temperature": 0.1,
          "max_tokens": 300,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Groq API Error: ${response.statusCode} - ${response.body}');
      }

      final data = jsonDecode(response.body);
      final String? responseText = data['choices']?[0]?['message']?['content'];

      if (responseText == null || responseText.isEmpty) {
        throw Exception('Received an empty response from Groq.');
      }

      // Cleanup markdown block if present (e.g. ```json ... ```)
      String cleanJson = responseText.trim();
      if (cleanJson.startsWith('```json')) {
        cleanJson = cleanJson.substring(7);
      } else if (cleanJson.startsWith('```')) {
        cleanJson = cleanJson.substring(3);
      }
      if (cleanJson.endsWith('```')) {
        cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      }

      cleanJson = cleanJson.trim();

      final decoded = jsonDecode(cleanJson) as Map<String, dynamic>;

      return {
        'food_name': decoded['food_name'] ?? 'Unknown Food',
        'calories': decoded['calories'] ?? 0,
        'protein': decoded['protein'] ?? 0,
        'carbs': decoded['carbs'] ?? 0,
        'fat': decoded['fat'] ?? 0,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error scanning food with Groq: $e');
      }
      throw 'Failed to analyze food. Ensure your API key is correct or try again. ($e)';
    }
  }
}
