import 'package:flutter/material.dart';
import '../services/groq_api.dart';
import '../models/meal_plan.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  // Selected diet
  String _selectedDiet = 'None';
  final List<String> _dietOptions = ['None', 'Keto', 'Halal', 'High-Protein', 'Nutritious'];
  
  // Quiz questions
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'How would you describe your cooking skill level?',
      'options': ['Beginner', 'Intermediate', 'Advanced'],
      'answer': 'Beginner',
    },
    {
      'question': 'How much time do you have for meal preparation?',
      'options': ['15 minutes or less', '30 minutes', '1 hour or more'],
      'answer': '30 minutes',
    },
    {
      'question': 'Do you have any food allergies?',
      'options': ['None', 'Dairy', 'Nuts', 'Gluten', 'Seafood'],
      'answer': 'None',
    },
    {
      'question': 'What is your primary goal for meal planning?',
      'options': ['Weight loss', 'Muscle building', 'Maintenance', 'Energy boost'],
      'answer': 'Maintenance',
    },
    {
      'question': 'How many people are you cooking for?',
      'options': ['Just me', '2 people', '3-4 people', '5+ people'],
      'answer': 'Just me',
    },
  ];
  
  // Meal plan data
  MealPlan? _mealPlan;
  bool _isLoading = false;
  
  // GroqAPI service
  final GroqApiService _groqApiService = GroqApiService();
  
  Future<void> _generateMealPlan() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Convert questions and answers to a string format to send to the API
      final String userPreferences = _questions.map((q) {
        return '${q['question']}: ${q['answer']}';
      }).join('\n');
      
      // Use GroqAPI service to generate meal plan
      final mealPlan = await _groqApiService.generateMealPlan(userPreferences, _selectedDiet);
      
      setState(() {
        _mealPlan = mealPlan;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating meal plan: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _exportToPdf() async {
    if (_mealPlan == null) return;
    
    try {
      // Show a simple toast/snackbar instead of generating PDF to avoid build issues
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF export would be implemented in the full version'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting PDF: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Meal Planner'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Diet filter dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Dietary Filter',
                  border: OutlineInputBorder(),
                ),
                value: _selectedDiet,
                items: _dietOptions
                    .map((diet) => DropdownMenuItem(
                          value: diet,
                          child: Text(diet),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDiet = value!;
                  });
                },
              ),
              
              const SizedBox(height: 30),
              
              // Quiz questions
              const Text(
                'Quick Preferences Quiz',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              
              ...List.generate(
                _questions.length,
                (index) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}. ${_questions[index]['question']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: List.generate(
                        _questions[index]['options'].length,
                        (optionIndex) => ChoiceChip(
                          label: Text(_questions[index]['options'][optionIndex]),
                          selected: _questions[index]['answer'] == _questions[index]['options'][optionIndex],
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _questions[index]['answer'] = _questions[index]['options'][optionIndex];
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Generate button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _generateMealPlan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Generate Meal Plan',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Generated meal plan
              if (_mealPlan != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '7-Day Meal Plan',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _exportToPdf,
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Export as PDF'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Days of the week
                ...List.generate(7, (dayIndex) {
                  final day = _mealPlan!.days[dayIndex];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Day ${dayIndex + 1}: ${day.name}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          const SizedBox(height: 10),
                          
                          // Breakfast
                          const Text(
                            'Breakfast',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(day.breakfast),
                          const SizedBox(height: 15),
                          
                          // Lunch
                          const Text(
                            'Lunch',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(day.lunch),
                          const SizedBox(height: 15),
                          
                          // Dinner
                          const Text(
                            'Dinner',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(day.dinner),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }
}