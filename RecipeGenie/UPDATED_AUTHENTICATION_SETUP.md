# Recipe Genie - Authentication Setup (Updated Instructions)

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

#### 5.1. Signing & Capabilities Setup

1. In Xcode, select your project in the navigator (left sidebar)
2. Select your app target (usually the same name as your project)
3. Go to the "Signing & Capabilities" tab at the top
4. You do NOT need to add "Background Modes" for this app - that was incorrect in previous instructions
5. Make sure your Team is selected under "Signing":
   - If you're developing personally, you can select "None" or add your Apple ID

#### 5.2. Add Environment Variables (CORRECT METHOD)

1. In Xcode's menu bar, go to **Product → Scheme → Edit Scheme**
   - Alternatively, you can press **Cmd + Shift + ,** (comma) and then select "Edit Scheme"
2. In the left sidebar of the scheme editor, select **"Run"**
3. Click on the **"Arguments" tab**
4. In the **"Environment Variables" section**, click the **"+" button**
5. Add these three variables:
   - Click the "+" button again for each variable:
   
   **Variable 1:**
   - Set **Name** to: `SUPABASE_URL`
   - Set **Value** to: `[Your actual Supabase Project URL]` (e.g., `https://your-project-id.supabase.co`)
   
   **Variable 2:**
   - Set **Name** to: `SUPABASE_KEY`
   - Set **Value** to: `[Your actual Supabase anon/public key]` (long string from your Supabase dashboard)
   
   **Variable 3:**
   - Set **Name** to: `GEMINI_API_KEY`
   - Set **Value** to: `[Your actual Google Gemini API key]` (from Google AI Studio)

6. Make sure the checkboxes next to each variable are checked
7. Click **"Close"** to save the scheme

### 6. Alternative Method: Info.plist (NOT RECOMMENDED for sensitive keys)

While it's technically possible to add environment variables through Info.plist, **this is NOT recommended** for API keys because:
- Keys in Info.plist can be extracted from the app binary
- It's harder to manage different keys for development/production

But if you must use Info.plist:
1. Select your project in Xcode
2. Go to the "Info" tab
3. Scroll to the bottom of the Info panel
4. Click the "+" button under "Custom iOS Target Properties"
5. Add rows with:
   - Key: `SUPABASE_URL`, Type: `String`, Value: [your URL]
   - Key: `SUPABASE_KEY`, Type: `String`, Value: [your key]
   - Key: `GEMINI_API_KEY`, Type: `String`, Value: [your key]

## Testing Authentication

1. **Clean and Build**:
   - Press **Cmd + Shift + K** to clean your project
   - Press **Cmd + B** to build your project
   - Make sure there are no build errors

2. **Run the App**:
   - Press **Cmd + R** to run the app in the simulator
   - Look for any error messages in the Xcode console

3. **Test Signup/Login**:
   - In the app, click "Login / Sign Up" in the header
   - Try creating a new account with a valid email and password
   - You should see messages in the Xcode console about authentication status

## Troubleshooting

### Common Issues

1. **"Missing Supabase environment variables"**
   - Double-check that you've added the variables in Product → Scheme → Edit Scheme → Run → Arguments
   - Make sure the variable names are exactly: `SUPABASE_URL`, `SUPABASE_KEY`, `GEMINI_API_KEY`
   - Make sure there are no extra spaces in the names or values
   - Restart Xcode after adding environment variables

2. **"Connection failed" or timeout errors**
   - Verify your internet connection
   - Check that your Supabase project is active (green status in dashboard)
   - Verify your API keys are correct
   - Make sure you're using the correct "anon" key, not the "service_role" key

3. **"Email already registered"**
   - Try logging in instead of signing up
   - Use a different email address
   - Check your Supabase Authentication dashboard to see existing users

4. **"Password too weak"**
   - Use a password that's at least 6 characters long
   - Include a mix of letters, numbers, and symbols

### Checking if Environment Variables are Set

To verify your environment variables are being picked up:
1. Add this temporary code to your app's initialization (e.g., in RecipeGenieApp.swift):
   ```swift
   init() {
       print("SUPABASE_URL: \(ProcessInfo.processInfo.environment["SUPABASE_URL"] ?? "NOT FOUND")")
       print("SUPABASE_KEY length: \(ProcessInfo.processInfo.environment["SUPABASE_KEY"]?.count ?? 0)")
       print("GEMINI_API_KEY length: \(ProcessInfo.processInfo.environment["GEMINI_API_KEY"]?.count ?? 0)")
   }
   ```
2. Run the app and check the Xcode console for these print statements

### Checking Database Records

1. In the Supabase dashboard, click "Table Editor" in the left sidebar
2. You should see the "profiles" table
3. After registering a user, you should see a record appear in this table

## Next Steps

Once authentication is working:
1. Test the recipe extraction with a logged-in user
2. Verify the extraction count is incremented correctly in the database
3. Test the paywall functionality with different user states
4. Try upgrading a user to "active" subscription status to bypass limits