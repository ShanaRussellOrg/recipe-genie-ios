# Recipe Genie - Authentication Setup

## Prerequisites

Before you can use the real authentication, you need to:

1. Have a Supabase account (https://supabase.io)
2. Create a Supabase project
3. Set up the database schema
4. Configure your Supabase credentials in Xcode

## Setting Up Supabase

### 1. Create a Supabase Project

1. Go to https://supabase.io and sign up or log in
2. Click "New project"
3. Fill in your project details:
   - Name: Recipe Genie
   - Database password: Create a strong password
   - Region: Choose the closest region to you
4. Click "Create new project" (this may take a few minutes)

### 2. Get Your API Keys

1. Once your project is created, click on it to open the dashboard
2. In the left sidebar, click "Project Settings" (gear icon)
3. Click "API"
4. Copy your:
   - Project URL (starts with https://)
   - anon key (this is your public API key)

### 3. Set Up the Database Schema

1. In the Supabase dashboard, click "SQL Editor" in the left sidebar
2. Click "New Query"
3. Copy and paste the contents of `database_schema.sql` into the editor
4. Click "Run" to execute the schema

### 4. Configure Authentication

1. In the Supabase dashboard, click "Authentication" in the left sidebar
2. Click "Providers"
3. Under "Email", make sure it's enabled
4. You can customize the email templates if desired

### 5. Configure Xcode Project

1. In Xcode, select your project in the navigator
2. Select your app target
3. Go to the "Signing & Capabilities" tab
4. Add the "Background Modes" capability if not already present
5. In the "Info" tab, you'll add your environment variables

### 6. Add Environment Variables

1. In Xcode, go to Product → Scheme → Edit Scheme
2. Select "Run" from the left sidebar
3. Click on the "Arguments" tab
4. In the "Environment Variables" section, click the "+" button
5. Add these variables:
   - Name: SUPABASE_URL
     Value: [Your Supabase Project URL]
   - Name: SUPABASE_KEY
     Value: [Your Supabase anon key]
   - Name: GEMINI_API_KEY
     Value: [Your Google Gemini API key]

## Testing Authentication

1. Build and run the app
2. Click "Login / Sign Up" in the header
3. Try creating a new account with a valid email and password
4. You should be able to log in with the same credentials

## Troubleshooting

### Common Issues

1. **"Supabase URL or Key not found"**
   - Make sure you've added the environment variables correctly
   - Check that there are no extra spaces in the values

2. **"Connection failed"**
   - Verify your internet connection
   - Check that your Supabase project is active
   - Verify your API keys are correct

3. **"Email already registered"**
   - Try logging in instead of signing up
   - Use a different email address

4. **"Password too weak"**
   - Use a password that's at least 6 characters long
   - Include a mix of letters, numbers, and symbols

### Checking Database Records

1. In the Supabase dashboard, click "Table Editor"
2. You should see the "profiles" table
3. After registering a user, you should see a record in this table

## Next Steps

Once authentication is working:
1. Test the recipe extraction with a logged-in user
2. Verify the extraction count is incremented correctly
3. Test the paywall functionality
4. Try upgrading a user to "active" subscription status to bypass limits