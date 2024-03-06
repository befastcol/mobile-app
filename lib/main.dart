import 'package:be_fast/providers/user.dart';
import 'package:be_fast/screens/home/courier/providers/courier_map_provider.dart';
import 'package:be_fast/screens/home/courier/providers/courier_state_provider.dart';
import 'package:be_fast/screens/home/courier/providers/courier_stream_provider.dart';
import 'package:be_fast/utils/user_session.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:be_fast/utils/firebase_options.dart';

import 'package:be_fast/screens/home/home/home.dart';
import 'package:be_fast/screens/login/login.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await initializeDateFormatting();
  await dotenv.load(fileName: ".env");
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => CourierStreamProvider()),
          ChangeNotifierProvider(create: (_) => CourierMapProvider()),
          ChangeNotifierProvider(create: (_) => CourierStateProvider()),
        ],
        child: const BeFast(),
      ),
    );
  });
}

class BeFast extends StatelessWidget {
  const BeFast({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Be Fast',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  AuthenticationWrapperState createState() => AuthenticationWrapperState();
}

class AuthenticationWrapperState extends State<AuthenticationWrapper> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: UserSession.getUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          String? userId = snapshot.data;
          if (userId == null) {
            return const Login();
          }
          return const Home();
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
