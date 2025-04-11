# FlavorLens

FlavorLens is a generative AI recipe & meal planner app built as a course project for Mobile Application Design Lab at Daffodil International University.

## Features

1. **Splash Screen**
   - Shows app logo and name for 2 seconds before navigating to the home screen

2. **Home Screen with Recipe Generation**
   - Image Input: Take or select photos of ingredients/foods
   - Voice Input: Record and transcribe requests for recipes
   - Text Input: Type recipe requests directly
   - Diet Filter: Choose from None, Keto, Halal, High-Protein, or Nutritious
   - Generated recipes include title, ingredients, steps, nutrition info, and images
   - Stores the last 5 recipes for quick access

3. **Weekly Meal Planner**
   - Form with diet filter and 5 MCQs for personalization
   - Generates a 7-day meal plan with breakfast, lunch, and dinner
   - Export as PDF functionality

4. **Profile Screen**
   - Shows number of recipes generated
   - Lists previously generated recipe titles

5. **About Screen**
   - App information and team details

## Setup Instructions

1. **Clone the repository**
   ```
   git clone https://github.com/yourusername/flavor_lens_app.git
   cd flavor_lens_app
   ```

2. **Install dependencies**
   ```
   flutter pub get
   ```

3. **Run the app**
   ```
   flutter run
   ```

## Tech Stack

- Flutter for UI
- Provider for state management
- SharedPreferences for local storage
- GroqCloud API (Claude 3) for AI generation
- Image Picker for camera/gallery access
- Record for audio recording
- PDF generation with printing package

## Team

- Md Mehedi Hasan Nayeem — 221‑15‑5049
- Md Mobashir Hasan — 221‑15‑5405
- Tanvirul Islam — 221‑15‑5386
- Azmira Shekh — 221‑15‑5569
- Md. Jahid Hasan — 221‑15‑5388

## Acknowledgments

- Md. Mezbaul Islam Zion (MIZ), Lecturer, DIU

## Notes for Development

- This is a student project built for Android only
- No authentication or Firebase is used; data is stored locally
- API keys should be kept secure in a production environment
