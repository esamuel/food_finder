import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lib/firebase_options.dart';

Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;

  // Create initial collections
  await firestore.collection('users').doc('placeholder').set({
    'created': FieldValue.serverTimestamp(),
  });

  await firestore.collection('foodItems').doc('placeholder').set({
    'created': FieldValue.serverTimestamp(),
  });

  print('Firestore collections initialized successfully!');

  // Delete placeholder documents
  await firestore.collection('users').doc('placeholder').delete();
  await firestore.collection('foodItems').doc('placeholder').delete();
}
