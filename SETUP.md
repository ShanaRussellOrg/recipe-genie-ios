# Recipe Genie iOS App Setup Guide

This guide will help you set up the Recipe Genie iOS app in Xcode.

## Prerequisites

1. Xcode 14.0 or later
2. A Google Gemini API key
3. A Supabase account (for authentication and profile management)

## Adding Source Files to Your Project

1. In Xcode, right-click on your project in the navigator and select "Add Files to "RecipeGenie"..."
2. Navigate to the `ios-app/RecipeGenie` directory
3. Select the following directories and files:
   - `Models/`
   - `Views/`
   - `ViewModels/`
   - `Services/`
   - `Utils/`
4. Make sure "Add to target" is checked for your RecipeGenie target
5. Click "Add"

## Setting Up Dependencies

### Google Gemini API

1. No additional dependencies are needed for the Gemini API as we're using URLSession
2. Add your API key using the instructions in `GEMINI_API_SETUP.md`

### Supabase (Optional for full implementation)

1. In Xcode, go to File → Add Package Dependencies
2. Enter the Supabase Swift SDK URL: `https://github.com/supabase/supabase-swift`
3. Follow the prompts to add the package to your project

## Configuring Supabase (Optional for full implementation)

1. Create a new Supabase project at https://supabase.io/
2. Get your project's URL and API key from the Supabase dashboard
3. Update the SupabaseClient in AuthService.swift with your actual URL and key

## Testing the App

1. Select a simulator or connected device
2. Press Cmd+R to build and run the app
3. Test the image selection and recipe extraction features

## Next Steps for Full Implementation

1. Implement the Supabase authentication and profile services in AuthService.swift and ProfileService.swift
2. Add proper error handling and user feedback
3. Implement in-app purchases for the premium features
4. Add unit and UI tests
5. Polish the UI/UX for iOS design guidelines
6. Submit to the App Store