import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        visualDensity: VisualDensity.adaptivePlatformDensity,
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
  String _firestoreStatus = 'Not tested';

  Future<void> testFirestore() async {
    try {
      // Write to Firestore
      await FirebaseFirestore.instance.collection('admin_tests').doc('sample').set({
        'title': 'Safe Buddy Admin Test',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'active',
      });
      print('Data written to Firestore');

      // Read from Firestore
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('admin_tests')
          .doc('sample')
          .get();
      if (doc.exists) {
        setState(() {
          _firestoreStatus = 'Data read: ${doc['title']}';
        });
      } else {
        setState(() {
          _firestoreStatus = 'No data found';
        });
      }
    } catch (e) {
      setState(() {
        _firestoreStatus = 'Error: $e';
      });
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
          ],
        ),
      ),
    );
  }
}