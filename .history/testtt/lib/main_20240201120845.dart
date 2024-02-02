import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as uif;
import 'package:flutter/material.dart';
import 'package:testtt/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  uif.FirebaseUIAuth.configureProviders([
    uif.PhoneAuthProvider(),
  ]);

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
            ? const LoginCustomWidget()
            : Text('Your Addrs: $userAddrs'),
      ),
    );
  }
}

class LoginCustomWidget extends StatefulWidget {
  const LoginCustomWidget({super.key});

  @override
  State<LoginCustomWidget> createState() => _LoginCustomWidgetState();
}

class _LoginCustomWidgetState extends State<LoginCustomWidget> {
  Widget child = const uif.PhoneInput(initialCountryCode: 'RO');

  @override
  Widget build(BuildContext context) {
    return uif.AuthStateListener<uif.PhoneAuthController>(
      listener: (oldState, newState, controller) {
        if (newState is uif.SMSCodeSent) {
          setState(() {
            child = uif.SMSCodeInput(
              onSubmit: (code) {
                controller.verifySMSCode(
                  code,
                  verificationId: newState.verificationId,
                  confirmationResult: newState.confirmationResult,
                );
              },
            );
          });
        }
        return null;
      },
      child: child,
    );
  }
}
