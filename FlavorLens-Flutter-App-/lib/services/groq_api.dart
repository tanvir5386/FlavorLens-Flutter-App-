import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';
import '../models/meal_plan.dart';

class GroqApiService {
  static const String _apiKey =
      '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';
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  Future<Recipe> generateRecipe(String input, String dietFilter) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'llama3-70b-8192',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a professional chef who creates recipes. Generate a recipe in JSON format with these fields: "title" (string), "ingredients" (array of strings), "steps" (array of strings), "nutrition" (string with nutrition facts).',
            },
            {
              'role': 'user',
              'content':
                  'Create a ${dietFilter != 'None' ? dietFilter : ''} recipe for $input. Return ONLY valid JSON with no additional text.',
            },
          ],
          'response_format': {'type': 'json_object'},
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final content = jsonResponse['choices'][0]['message']['content'];
        final recipeData = jsonDecode(content);

        // Ensure all required fields are present and of correct type
        if (recipeData is Map<String, dynamic> &&
            recipeData.containsKey('title') &&
            recipeData.containsKey('ingredients') &&
            recipeData.containsKey('steps') &&
            recipeData.containsKey('nutrition')) {
          return Recipe(
            title: recipeData['title'].toString(),
            ingredients: List<String>.from(recipeData['ingredients']),
            steps: List<String>.from(recipeData['steps']),
            imageUrl:
                'https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D,$input',
            nutrition: recipeData['nutrition'].toString(),
          );
        } else {
          throw Exception('Invalid recipe data format received from API');
        }
      } else {
        throw Exception(
          'API request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to generate recipe: $e');
    }
  }

  Future<MealPlan> generateMealPlan(
    String preferences,
    String dietFilter,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'llama3-70b-8192',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a nutrition expert who creates meal plans. Generate a 7-day meal plan in JSON format with an array called "days" containing objects with these fields: "name" (day of week), "breakfast", "lunch", and "dinner".',
            },
            {
              'role': 'user',
              'content':
                  'Create a 7-day meal plan with these preferences: $preferences. Diet type: ${dietFilter != 'None' ? dietFilter : 'balanced'}. Return ONLY valid JSON with no additional text.',
            },
          ],
          'response_format': {'type': 'json_object'},
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final content = jsonResponse['choices'][0]['message']['content'];
        final mealPlanData = jsonDecode(content);

        final List<DayPlan> days =
            (mealPlanData['days'] as List)
                .map(
                  (day) => DayPlan(
                    name: day['name'],
                    breakfast: day['breakfast'],
                    lunch: day['lunch'],
                    dinner: day['dinner'],
                  ),
                )
                .toList();

        return MealPlan(days: days);
      } else {
        throw Exception(
          'API request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to generate meal plan: $e');
    }
  }
}
