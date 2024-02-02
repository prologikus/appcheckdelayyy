import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/material.dart';
import 'package:testtt/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final FirebaseAuth auth;
  late final FirebaseFirestore firestore;

  bool showLogin = false;
  String? userAddrs;

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    firestore = FirebaseFirestore.instance;

    automaticLogin();
  }

  void automaticLogin() async {
    auth.authStateChanges().listen((user) async {
      if (user == null) {
        setState(() {
          showLogin = true;
        });
      } else {
        var profileSnap = await firestore
            .collection("users")
            .doc(auth.currentUser!.uid)
            .get();

        setState(() {
          userAddrs = profileSnap.get("addresses").toString();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: showLogin
            ? FirebasePhoneAuthHandler(
                phoneNumber: "+40721805843",
                builder: (context, controller) {
                  return SizedBox.shrink();
                },
              )
            : Text('Your Addrs: $userAddrs'),
      ),
    );
  }
}
