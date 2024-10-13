import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';  
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAfOYUi46ZtuDrdyFLf88DsazSYnonhR4I",               
      authDomain: "emergency-report-app-beef3.firebaseapp.com",       
      projectId: "emergency-report-app-beef3",                         
      storageBucket: "emergency-report-app-beef3.appspot.com",         
      messagingSenderId: "211710220757",                              
      appId: "1:211710220757:android:e5c1dd9c1e28f31aac855c",           
      measurementId: "",                                                
    ),
  );

  runApp(MyApp()); 
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community Emergency Reporting',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}
