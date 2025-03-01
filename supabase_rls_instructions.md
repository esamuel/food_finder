# Supabase Row Level Security (RLS) Policy Instructions

The error `PostgrestException(message: new row violates row-level security policy for table "profiles", code: 42501)` indicates that the current RLS policies for the `profiles` table are preventing the creation of new profiles.

## How to Fix the RLS Policy

1. Log in to your Supabase dashboard at https://app.supabase.com/
2. Select your project (with URL: https://wbagdipqiclrcpcehfoo.supabase.co)
3. Go to the "Table Editor" in the left sidebar
4. Find and select the "profiles" table
5. Click on the "Policies" tab

## Required Policies for the Profiles Table

You need to create the following policies:

### 1. Enable users to create their own profile

```sql
CREATE POLICY "Users can create their own profile"
ON profiles
FOR INSERT
WITH CHECK (auth.uid() = id);
```

### 2. Enable users to read any profile

```sql
CREATE POLICY "Anyone can read profiles"
ON profiles
FOR SELECT
USING (true);
```

### 3. Enable users to update their own profile

```sql
CREATE POLICY "Users can update their own profile"
ON profiles
FOR UPDATE
USING (auth.uid() = id);
```

### 4. Enable users to delete their own profile (optional)

```sql
CREATE POLICY "Users can delete their own profile"
ON profiles
FOR DELETE
USING (auth.uid() = id);
```

## Alternative: Enable RLS but Allow All Operations (for Development Only)

If you're just testing and want to temporarily disable RLS restrictions:

```sql
CREATE POLICY "Allow all operations for now"
ON profiles
FOR ALL
USING (true)
WITH CHECK (true);
```

**Note:** This is not recommended for production as it removes all security restrictions.

## Verify Table Structure

Make sure your profiles table has the following structure:
- `id` (UUID, Primary Key) - should match the user's auth.uid()
- `created_at` (timestamp with time zone)
- `email` (text)
- `display_name` (text)
- Other optional fields

## Testing After Policy Update

After updating the policies, try the sign-up process again. The error should be resolved, and users should be able to create their profiles during registration.
