# How to Add Supabase Swift Package to Your Project

## Prerequisites

Before you can use the real Supabase authentication, you need to add the Supabase Swift Package to your Xcode project.

## Adding the Supabase Swift Package

### Step 1: Open Your Project in Xcode

1. Launch Xcode
2. Open your RecipeGenie project

### Step 2: Add Package Dependencies

1. In the Xcode menu, go to **File** → **Add Package Dependencies...**
   - If you don't see this option, make sure you're in your project workspace
   
   **Alternative method**:
   - Go to **File** → **Add Packages...**

### Step 3: Enter the Supabase Repository URL

1. In the search field, enter:
   ```
   https://github.com/supabase/supabase-swift
   ```

2. Click **Add Package**

### Step 4: Configure Package Options

1. Xcode will fetch the package information
2. Make sure these settings are selected:
   - **Dependency Rule**: "Up to Next Major Version" (or "Exact Version" if you prefer a specific version)
   - **Branch**: "main" or a specific version tag

3. Click **Add Package**

### Step 5: Add to Target

1. Xcode will show you the available libraries from the Supabase package
2. Make sure your RecipeGenie target is checked
3. Click **Add** or **Done**

### Step 6: Verify Installation

1. In the left sidebar (Project Navigator), you should now see:
   - A **Package Dependencies** folder
   - The **Supabase** package listed there

2. In your project settings:
   - Select your project
   - Go to the **Package Dependencies** tab
   - You should see **supabase-swift** listed

### Step 7: Clean and Build

1. Clean your project:
   - **Product** → **Clean Build Folder** (Cmd+Shift+K)

2. Build your project:
   - **Product** → **Build** (Cmd+B)

3. If there are no errors, the package was installed successfully

## Troubleshooting Package Installation

### Common Issues and Solutions

1. **"No such module 'Supabase'" error persists**:
   - Make sure you've added the package to your target
   - Try cleaning the build folder (**Product** → **Clean Build Folder**)
   - Restart Xcode
   - Check that your Xcode version supports Swift Packages

2. **"Package Resolution Failed"**:
   - Check your internet connection
   - Make sure the URL is correct: `https://github.com/supabase/supabase-swift`
   - Try again in a few minutes (GitHub might be temporarily unavailable)

3. **"Unable to resolve package"**:
   - Make sure you're using Xcode 11.4 or later
   - Check that your Mac can access GitHub (try opening the URL in a browser)

4. **Package shows as "unavailable"**:
   - Go to **File** → **Packages** → **Reset Package Caches**
   - Wait for Xcode to re-download the package information

## Manual Package Addition (if the above doesn't work)

If the standard method doesn't work, you can manually add the package:

### Method 1: Edit Package.swift (for Swift Package projects)

1. If your project has a `Package.swift` file, open it
2. Add this to the `dependencies` array:
   ```swift
   .package(url: "https://github.com/supabase/supabase-swift", from: "2.0.0")
   ```

3. Add `"Supabase"` to your target's dependencies:
   ```swift
   .target(
       name: "YourTargetName",
       dependencies: ["Supabase"]),
   ```

### Method 2: Direct Download (not recommended)

1. Download the repository from GitHub: https://github.com/supabase/supabase-swift
2. Extract the files
3. Drag the source files into your Xcode project
4. Add them to your target

**Note**: This method is not recommended as you won't get automatic updates

## Verifying the Installation

After installing the package, you should be able to:

1. Import Supabase in your Swift files:
   ```swift
   import Supabase
   ```

2. Create a SupabaseClient instance:
   ```swift
   let supabase = SupabaseClient(
       supabaseURL: "YOUR_SUPABASE_URL",
       supabaseKey: "YOUR_SUPABASE_KEY"
   )
   ```

3. Build without import errors

## Next Steps

Once the Supabase package is installed successfully:

1. Add your Supabase credentials to the environment variables
2. Test the authentication
3. Verify the database connection
4. Test the paywall functionality

The package installation is the first step to getting the real authentication working in your app.