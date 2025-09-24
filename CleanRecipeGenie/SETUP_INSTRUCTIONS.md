# Instructions to Create a Clean Recipe Genie Project

## Step 1: Create a New Xcode Project

1. Open Xcode
2. Select "Create a new Xcode project" or go to File > New > Project
3. Choose "App" under iOS templates
4. Fill in the project details:
   - Product Name: RecipeGenie
   - Team: Your development team (or "None" for personal development)
   - Interface: SwiftUI
   - Language: Swift
   - Bundle Identifier: com.yourcompany.RecipeGenie (change as needed)
5. Save the project in the CleanRecipeGenie directory

## Step 2: Replace the Generated Files

1. Replace the generated `RecipeGenieApp.swift` file with the one we created
2. You can copy the content from:
   `/Users/shana.russell/Dropbox (Personal)/_software projects/RecipeGenie ios App/recipe-genie/ios-app/RecipeGenie/CleanRecipeGenie/RecipeGenieApp.swift`

## Step 3: Add Supabase Swift Package (Optional)

If you want to use Supabase for authentication and database:

1. In Xcode, go to File > Add Package Dependencies
2. Enter the Supabase Swift SDK URL: `https://github.com/supabase/supabase-swift`
3. Follow the prompts to add the package to your project

## Step 4: Add Google Gemini API Key

1. In Xcode, select your project in the navigator
2. Select your app target
3. Go to the "Info" tab
4. Add a new entry with key "GEMINI_API_KEY" and your actual Google Gemini API key as the value

## Step 5: Build and Run

1. Select a simulator or connected device
2. Press Cmd+R to build and run the app

## Next Steps

Once you have the basic project working, you can gradually add the more complex features:

1. Add the image picker functionality
2. Implement the Google Gemini API service
3. Add user authentication (with or without Supabase)
4. Implement the recipe extraction and display features
5. Add the pricing and subscription features