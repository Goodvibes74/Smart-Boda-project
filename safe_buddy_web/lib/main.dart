import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe Buddy Admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _firestoreStatus = 'Not tested'; // Reused for auth status

  // Existing Firestore test (unchanged)
  Future<void> testFirestore() async {
    try {
      await FirebaseFirestore.instance.collection('admin_tests').doc('sample').set({
        'title': 'Safe Buddy Admin Test',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'active',
      });
      print('Data written to Firestore');
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('admin_tests')
          .doc('sample')
          .get();
      if (doc.exists) {
        setState(() {
          _firestoreStatus = 'Firestore: ${doc['title']}';
        });
      }
    } catch (e) {
      setState(() {
        _firestoreStatus = 'Firestore error: $e';
      });
    }
  }

  // New Authentication test
  Future<void> testAuth() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: 'test@safebuddy.com',
        password: 'Test123456',
      );
      setState(() {
        _firestoreStatus = 'Logged in: ${userCredential.user?.email}';
      });
      print('Authentication successful for ${userCredential.user?.email}');
    } catch (e) {
      setState(() {
        _firestoreStatus = 'Auth error: $e';
      });
      print('Authentication error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Buddy Admin'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_firestoreStatus),
            ElevatedButton(
              onPressed: testFirestore,
              child: const Text('Test Firestore'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: testAuth,
              child: const Text('Test Authentication'),
            ),
          ],
        ),
      ),
    );
  }
}