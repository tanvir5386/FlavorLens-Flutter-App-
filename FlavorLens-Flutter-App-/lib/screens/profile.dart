
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _recipeCount = 0;
  List<Recipe> _recentRecipes = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }
  
  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load recipe count
    final recipeCount = prefs.getInt('recipeCount') ?? 0;
    
    // Load recent recipes
    final recipesJson = prefs.getStringList('recentRecipes') ?? [];
    final recipes = recipesJson.map((json) => Recipe.fromJson(jsonDecode(json))).toList();
    
    setState(() {
      _recipeCount = recipeCount;
      _recentRecipes = recipes;
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User info card
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.deepOrange,
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'FlavorLens User',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Recipes Generated: $_recipeCount',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Recent recipes
                    const Text(
                      'Your Recent Recipes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (_recentRecipes.isEmpty)
                      const Center(
                        child: Text(
                          'No recipes generated yet!',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _recentRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = _recentRecipes[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(
                                recipe.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${recipe.ingredients.length} ingredients • ${recipe.steps.length} steps',
                              ),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.deepOrange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.restaurant,
                                  color: Colors.deepOrange,
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                // Here you could navigate to the recipe details
                                // or pass back the recipe to show on home screen
                              },
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}