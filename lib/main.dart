import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'services/supabase_service.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/home/home_screen.dart';
import 'core/services/auth/auth_service.dart';
import 'core/services/auth/supabase_auth_service.dart';

// Supabase URL and anon key - replace with your own
const String supabaseUrl =
    'https://wbagdipqiclrcpcehfoo.supabase.co'; // Replace with your Supabase project URL
const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndiYWdkaXBxaWNscmNwY2VoZm9vIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDA4MDYzNjksImV4cCI6MjA1NjM4MjM2OX0.m35bxmxu4ywXl4E6dO3E-QNMyvSbbg6HxPjrvqekoCk'; // Replace with your Supabase anon key

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Add debug prints
  print('Initializing Supabase with URL: $supabaseUrl');

  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: false,
    );
    print('Supabase initialized successfully');

    // Create a global Supabase client instance for easy access throughout the app
    final supabase = Supabase.instance.client;

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SupabaseService()),
          Provider<AuthService>(create: (_) => SupabaseAuthService()),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print('Error initializing Supabase: $e');
    // Show error app instead
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red[100],
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 80, color: Colors.red),
                  const SizedBox(height: 20),
                  const Text(
                    'Supabase Connection Error',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Error details: $e',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Please check your Supabase URL and anon key in lib/main.dart',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const SupabaseTestPage(), // Use test page first
    );
  }
}

// Test page to verify Supabase connection
class SupabaseTestPage extends StatefulWidget {
  const SupabaseTestPage({super.key});

  @override
  State<SupabaseTestPage> createState() => _SupabaseTestPageState();
}

class _SupabaseTestPageState extends State<SupabaseTestPage> {
  String _status = 'Testing Supabase connection...';
  bool _isLoading = true;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    try {
      // Test if we can access Supabase
      final client = Supabase.instance.client;
      final response =
          await client.from('profiles').select('id').limit(1).maybeSingle();

      setState(() {
        _status =
            'Supabase connection successful! You can now proceed to the app.';
        _isLoading = false;
        _isSuccess = true;
      });
    } catch (e) {
      setState(() {
        _status = 'Supabase connection error: $e';
        _isLoading = false;
        _isSuccess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Connection Test'),
        backgroundColor: _isSuccess ? Colors.green : Colors.orange,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator()
              else
                Icon(
                  _isSuccess ? Icons.check_circle : Icons.error_outline,
                  size: 80,
                  color: _isSuccess ? Colors.green : Colors.orange,
                ),
              const SizedBox(height: 20),
              Text(
                _status,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              if (_isSuccess)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AuthWrapper()),
                    );
                  },
                  child: const Text('Continue to App'),
                )
              else
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                      _status = 'Retesting Supabase connection...';
                    });
                    _testConnection();
                  },
                  child: const Text('Retry Connection Test'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseService = context.watch<SupabaseService>();
    print('AuthWrapper build called');

    return StreamBuilder<AuthState>(
      stream: supabaseService.authStateChanges,
      builder: (context, snapshot) {
        print('StreamBuilder update: ${snapshot.connectionState}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          print('Connection state: waiting');
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          print('StreamBuilder error: ${snapshot.error}');
          return Scaffold(
            backgroundColor: Colors.orange[100],
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 80, color: Colors.orange),
                    const SizedBox(height: 20),
                    const Text(
                      'Authentication Error',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Error details: ${snapshot.error}',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final session = snapshot.data?.session;
        print('Session: ${session != null ? 'Active' : 'Null'}');

        if (session != null) {
          print('Navigating to HomeScreen');
          return const HomeScreen();
        }

        print('Navigating to SignInScreen');
        return const SignInScreen();
      },
    );
  }
}
