# Email Confirmation Setup for iOS App

This guide explains how to configure Supabase email confirmation to work with your iOS app instead of redirecting to localhost.

## Problem

By default, Supabase email confirmation links redirect to `http://localhost:3000`, which doesn't work for mobile apps. This causes users to see a broken webpage when they click the confirmation link from their email.

## Solution

Configure Supabase to use a custom URL scheme that your iOS app can handle.

## Step 1: Configure Supabase Dashboard

1. **Go to your Supabase Dashboard**
   - Navigate to [supabase.com](https://supabase.com)
   - Select your Recipe Genie project

2. **Open Authentication Settings**
   - Click "Authentication" in the left sidebar
   - Click "URL Configuration" (or "Auth" → "Settings")

3. **Update Redirect URLs**
   - Find the "Redirect URLs" section
   - Add this URL: `recipegenie://auth/callback`
   - Remove or disable any localhost URLs like `http://localhost:3000`

4. **Update Site URL (if needed)**
   - Set Site URL to: `recipegenie://auth/callback`
   - Or keep it as your web app URL if you have one

5. **Save Changes**
   - Click "Save" or "Update" to apply the changes

## Step 2: Verify iOS App Configuration (Already Done)

The iOS app has already been configured with:

✅ **URL Scheme in Info.plist:**
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>recipegenie.auth</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>recipegenie</string>
        </array>
    </dict>
</array>
```

✅ **Deep Link Handling in App:**
- The app handles `recipegenie://auth/callback` URLs
- Extracts authentication tokens from the URL
- Updates the authentication state automatically

✅ **Updated Signup Method:**
- Supabase signup now includes `redirectTo: URL(string: "recipegenie://auth/callback")`

## How It Works Now

1. **User signs up** → Supabase sends confirmation email
2. **User clicks link in email** → Opens URL like: `recipegenie://auth/callback?access_token=...&refresh_token=...`
3. **iOS automatically opens your app** → Deep link handling activates
4. **App processes the tokens** → User is automatically logged in
5. **User sees success** → No more localhost errors!

## Testing

1. **Sign up** with a new email address
2. **Check your email** for the confirmation link
3. **Click the link** on your iPhone/iPad
4. **Your app should open** automatically
5. **Check the Xcode console** for success logs

## Troubleshooting

**If the link still goes to localhost:**
- Double-check the Supabase dashboard redirect URLs
- Make sure you saved the changes
- Try signing up with a new email address (old emails may still have old URLs)

**If the app doesn't open:**
- Verify the URL scheme in Info.plist
- Check that the device has the app installed
- Test the URL scheme manually with Safari: `recipegenie://test`

**If tokens aren't processed:**
- Check Xcode console for deep link handling logs
- Verify the URL format matches what Supabase sends

## Advanced Configuration

For production apps, you may want to:

1. **Use different URL schemes** for development vs production
2. **Add error handling** for invalid tokens
3. **Show success/error UI** to the user
4. **Store tokens securely** in Keychain
5. **Implement automatic session refresh**

The current implementation provides a solid foundation for email confirmation that works properly with iOS apps.