import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../widgets/recipe_card.dart';
import '../models/recipe.dart';
import '../services/groq_api.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Input mode selection
  int _selectedInputMode = 0;
  final List<String> _inputModes = ['Image', 'Text'];

  // Diet filter options
  String _selectedDiet = 'None';
  final List<String> _dietOptions = [
    'None',
    'Keto',
    'Halal',
    'High-Protein',
    'Nutritious',
  ];

  // Input data holders
  File? _imageFile;
  final TextEditingController _textInputController = TextEditingController();

  // Recipe data
  Recipe? _currentRecipe;
  List<Recipe> _recentRecipes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRecentRecipes();
  }

  // GroqAPI service
  final GroqApiService _groqApiService = GroqApiService();

  Future<void> _loadRecentRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJson = prefs.getStringList('recentRecipes') ?? [];

    setState(() {
      _recentRecipes =
          recipesJson.map((json) => Recipe.fromJson(jsonDecode(json))).toList();
    });
  }

  Future<void> _saveRecentRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final recipesJson =
        _recentRecipes.map((recipe) => jsonEncode(recipe.toJson())).toList();

    // Keep only last 5 recipes
    if (recipesJson.length > 5) {
      recipesJson.removeRange(5, recipesJson.length);
    }

    await prefs.setStringList('recentRecipes', recipesJson);

    // Update recipe count for profile screen
    int recipeCount = prefs.getInt('recipeCount') ?? 0;
    await prefs.setInt('recipeCount', recipeCount + 1);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _textInputController.clear();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<void> _generateRecipe() async {
    String inputData = '';

    // Get input based on selected mode
    if (_selectedInputMode == 0 && _imageFile != null) {
      // For simplicity, we're mocking image recognition
      inputData = 'Pasta with tomatoes, basil, and cheese';
    } else if (_selectedInputMode == 1) {
      inputData = _textInputController.text;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide input first')),
      );
      return;
    }

    if (inputData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide valid input')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Use GroqAPI service to generate recipe
      final recipe = await _groqApiService.generateRecipe(
        inputData,
        _selectedDiet,
      );

      setState(() {
        _currentRecipe = recipe;

        // Add to recent recipes and save
        _recentRecipes.insert(0, recipe);
        if (_recentRecipes.length > 5) {
          _recentRecipes.removeLast();
        }
      });

      // Save to local storage
      await _saveRecentRecipes();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error generating recipe: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildInputSection() {
    switch (_selectedInputMode) {
      case 0: // Image
        return Column(
          children: [
            const SizedBox(height: 20),
            _imageFile != null
                ? Image.file(
                  _imageFile!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                : Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 80, color: Colors.grey),
                ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ],
            ),
          ],
        );

      case 1: // Text
        return Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: _textInputController,
              decoration: const InputDecoration(
                hintText: 'Describe the food or recipe you want...',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 5,
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlavorLens'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => Navigator.pushNamed(context, '/planner'),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.pushNamed(context, '/about'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input mode selection
              Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: List.generate(
                    _inputModes.length,
                    (index) => Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedInputMode = index;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                _selectedInputMode == index
                                    ? Colors.deepOrange
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                              _inputModes[index],
                              style: TextStyle(
                                color:
                                    _selectedInputMode == index
                                        ? Colors.white
                                        : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Diet filter dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Dietary Filter',
                  border: OutlineInputBorder(),
                ),
                value: _selectedDiet,
                items:
                    _dietOptions
                        .map(
                          (diet) =>
                              DropdownMenuItem(value: diet, child: Text(diet)),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDiet = value!;
                  });
                },
              ),

              // Input section (varies based on selected mode)
              _buildInputSection(),

              const SizedBox(height: 20),

              // Generate button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _generateRecipe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            'Generate Recipe',
                            style: TextStyle(fontSize: 18),
                          ),
                ),
              ),

              const SizedBox(height: 30),

              // Generated recipe
              if (_currentRecipe != null) RecipeCard(recipe: _currentRecipe!),

              const SizedBox(height: 20),

              // Recent recipes section
              if (_recentRecipes.isNotEmpty) ...[
                const Text(
                  'Recent Recipes',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...List.generate(
                  _recentRecipes.length,
                  (index) => ListTile(
                    title: Text(_recentRecipes[index].title),
                    subtitle: Text(
                      '${_recentRecipes[index].ingredients.length} ingredients • ${_recentRecipes[index].steps.length} steps',
                    ),
                    leading: const Icon(Icons.restaurant_menu),
                    onTap: () {
                      setState(() {
                        _currentRecipe = _recentRecipes[index];
                      });
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textInputController.dispose();
    super.dispose();
  }
}
