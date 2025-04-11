class Recipe {
  final String title;
  final List<String> ingredients;
  final List<String> steps;
  final String imageUrl;
  final String nutrition;
  
  Recipe({
    required this.title,
    required this.ingredients,
    required this.steps,
    required this.imageUrl,
    required this.nutrition,
  });
  
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      title: json['title'],
      ingredients: List<String>.from(json['ingredients']),
      steps: List<String>.from(json['steps']),
      imageUrl: json['imageUrl'],
      nutrition: json['nutrition'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'ingredients': ingredients,
      'steps': steps,
      'imageUrl': imageUrl,
      'nutrition': nutrition,
    };
  }
}