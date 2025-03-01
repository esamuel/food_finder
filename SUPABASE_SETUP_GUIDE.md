# Supabase Setup Guide for Food Finder App

## Running the Updated SQL Script

I've updated the SQL script to handle cases where policies already exist. Follow these steps to run it:

1. Go to your Supabase dashboard at https://app.supabase.com/
2. Navigate to the SQL Editor
3. Create a new query
4. Copy and paste the entire contents of the updated `supabase_setup.sql` file
5. Run the query

This updated script uses `IF NOT EXISTS` checks to prevent errors when policies already exist. It will:
- Create the profiles table if it doesn't exist
- Enable Row Level Security on the profiles table
- Create policies for the profiles table only if they don't already exist
- Create policies for the storage bucket only if they don't already exist

## Verifying Your Setup

After running the script, verify that everything is set up correctly:

### 1. Check the Profiles Table

1. Go to Table Editor in your Supabase dashboard
2. You should see a `profiles` table with these columns:
   - `id` (UUID, Primary Key)
   - `email` (Text)
   - `display_name` (Text)
   - `avatar_url` (Text)
   - `created_at` (Timestamp)
   - `updated_at` (Timestamp)

### 2. Check Row Level Security Policies

1. Go to Authentication > Policies
2. Look for the `profiles` table
3. Verify it has these policies:
   - "Users can view their own profile"
   - "Users can update their own profile"
   - "Users can insert their own profile"

### 3. Check Storage Bucket

1. Go to Storage
2. Make sure you have a bucket named `food_images`
3. Go to Storage > Policies
4. Verify it has these policies:
   - "Users can upload their own images"
   - "Anyone can view images"

### 4. Test the App

1. Run your Flutter app
2. You should see the Supabase Connection Test screen
3. If the connection is successful, you'll see a green checkmark
4. Click "Continue to App" to proceed to the authentication screen

## Troubleshooting

If you encounter any issues:

1. Check the browser console (F12) for error messages
2. Refer to the `TROUBLESHOOTING.md` file for common issues and solutions
3. Make sure your Supabase URL and anon key in `lib/main.dart` are correct
4. Verify that your Supabase project is active and not in maintenance mode

Remember that the first time a user signs up, a profile record needs to be created. The app is designed to do this automatically when a user registers. 