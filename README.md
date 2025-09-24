# Recipe Genie iOS App

This is the iOS version of the Recipe Genie application, converted from the original React web app. It allows users to extract recipes from images of handwritten recipes using Google's Gemini AI.

## Features

- Image selection from photo library
- Recipe extraction using Google Gemini AI
- User authentication (to be fully implemented)
- Usage limits for free users
- Premium upgrade option

## Setup

1. Open the project in Xcode
2. Set your Google Gemini API key using the instructions in `GEMINI_API_SETUP.md`

## Project Structure

- `Models/`: Data models (Recipe, User, Profile)
- `Views/`: SwiftUI views
- `ViewModels/`: View models for state management
- `Services/`: API services (Gemini, Supabase Auth, Profile)
- `Utils/`: Utility functions

## Dependencies

This project uses only native iOS frameworks. For a production app, you might want to add:

- Supabase iOS SDK for authentication
- Kingfisher or similar for image handling
- SwiftLint for code quality

## Next Steps

To fully implement this app, you would need to:

1. Integrate the Supabase iOS SDK for authentication and profile management
2. Implement the actual API calls to Supabase
3. Add proper error handling and user feedback
4. Implement in-app purchases for the premium features
5. Add unit and UI tests
6. Polish the UI/UX for iOS design guidelines