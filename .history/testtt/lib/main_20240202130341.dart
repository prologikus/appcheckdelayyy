import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:testtt/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    webProvider:
        ReCaptchaV3Provider('6LckOMwnAAAAAGFnfWDKrOpJFsTTFJqnXb_w7Ky5'),
    androidProvider:
        kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.appAttest,
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

  bool loggedIn = false;
  String? userAddrs;
  int timeInit = DateTime.now().millisecondsSinceEpoch;
  String doneMessage = "";

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
          loggedIn = false;
        });

        var verificationCode = "";
        var completer = Completer();

        await auth.verifyPhoneNumber(
            phoneNumber: "+40721805843",
            verificationCompleted: (a) {},
            verificationFailed: (a) {},
            codeSent: (a, b) {
              verificationCode = a;
              completer.complete();
            },
            codeAutoRetrievalTimeout: (a) {});

        await completer.future;

        await auth.signInWithCredential(PhoneAuthProvider.credential(
            verificationId: verificationCode, smsCode: "123456"));
      } else {
        var profileSnap = await firestore
            .collection("users")
            .doc(auth.currentUser!.uid)
            .get();

        setState(() {
          loggedIn = true;
          userAddrs = profileSnap.get("addresses").toString();
          doneMessage =
              "${DateTime.now().millisecondsSinceEpoch - timeInit} ms";
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
            child: Text(
                "Logged in: $loggedIn, \n\nAddresses: $userAddrs \n\n$doneMessage")));
  }
}
