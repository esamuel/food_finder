# Troubleshooting Supabase Integration

If you're experiencing issues with your Supabase integration in the Food Finder app, follow this troubleshooting guide.

## Blank Screen Issues

If you're seeing a blank screen when running the app, it's likely due to one of these issues:

### 1. Incorrect Supabase Credentials

Make sure your Supabase URL and anon key in `lib/main.dart` are correct:

```dart
const String supabaseUrl = 'https://your-project-id.supabase.co';
const String supabaseAnonKey = 'your-anon-key';
```

Both values must be from the same project. You can find these values in your Supabase dashboard under Project Settings > API.

### 2. Missing Database Tables

You need to set up the required database tables in your Supabase project:

1. Go to your Supabase dashboard
2. Click on "SQL Editor"
3. Create a new query
4. Copy and paste the SQL from the `supabase_setup.sql` file
5. Run the query

### 3. Storage Bucket Not Set Up

You need to create a storage bucket for images:

1. Go to your Supabase dashboard
2. Click on "Storage"
3. Click "Create new bucket"
4. Name it `food_images`
5. Set it to "Public"
6. After creating the bucket, go to the SQL Editor and run the storage policies from the `supabase_setup.sql` file

### 4. Network Issues

If you're running the app on a device or emulator, make sure it has internet access. For web, check your browser console for network errors.

## Authentication Issues

If you can see the sign-in screen but can't sign in or sign up:

### 1. Check Email Confirmation Settings

By default, Supabase requires email confirmation. To disable this for testing:

1. Go to your Supabase dashboard
2. Click on "Authentication" > "Providers"
3. Scroll down to "Email"
4. Toggle off "Enable email confirmations"
5. Click "Save"

### 2. Check Browser Console for Errors

If you're running on web, open the browser console (F12) to see any JavaScript errors.

### 3. Check Supabase Logs

1. Go to your Supabase dashboard
2. Click on "Database" > "Logs"
3. Look for any errors related to authentication

## Storage Issues

If you can't upload images:

### 1. Check Storage Bucket Policies

Make sure your storage bucket has the correct policies:

1. Go to your Supabase dashboard
2. Click on "Storage" > "Policies"
3. Make sure you have policies that allow authenticated users to upload files and anyone to view files

### 2. Check File Size

Supabase has a default file size limit. Make sure your images aren't too large.

## Database Issues

If you're having issues with the profiles table:

### 1. Check Table Structure

Make sure your profiles table has the correct structure:

1. Go to your Supabase dashboard
2. Click on "Table Editor"
3. Check if the "profiles" table exists and has the correct columns

### 2. Check RLS Policies

Make sure Row Level Security is enabled and the correct policies are in place:

1. Go to your Supabase dashboard
2. Click on "Authentication" > "Policies"
3. Check if the profiles table has the correct policies

## Debug Mode

To enable more detailed logging, make sure debug mode is enabled in your Supabase initialization:

```dart
await Supabase.initialize(
  url: supabaseUrl,
  anonKey: supabaseAnonKey,
  debug: true, // Enable debug mode
);
```

## Still Having Issues?

If you're still experiencing problems after following these steps:

1. Check the Flutter console for any error messages
2. Look at the browser console (if running on web)
3. Try running the app on a different device or platform
4. Make sure your Supabase project is on the free tier or has enough credits
5. Check if your Supabase project is in maintenance mode 