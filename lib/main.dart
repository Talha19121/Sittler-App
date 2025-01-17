import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:sittler_app/Controller-Provider/Booking-Provider/booking-provider.dart';

import 'Controller-Provider/Staff-Controller/signin-signup-controller-staff.dart';
import 'Controller-Provider/Theme-Controller/theme-controler-provider.dart';

import 'Controller-Provider/User-Controller/user-signup-signin.dart';
import 'Pages/Home-Screen/home.dart';
import 'Pages/Onboarding-Screen/onboarding.dart';
import 'Pages/Staff/staff-home.dart';
import 'Pages/User/user-home.dart';
import 'Pages/User/user-signin.dart';
import 'Pages/User/user-signup.dart';
import 'Theme/Theme-Constant/theme-constant.dart';

import 'Widgets/elevated-button.dart';
import 'Widgets/sizebox.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // final prefs = await SharedPreferences.getInstance();
  // final showHome = prefs.getBool("showHome") ?? false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => SignUpSignInController()),
        ChangeNotifierProvider(create: (_) => SignUpSignInControllerStaff()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var userLoggedIn;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();

    userLoggedIn = FirebaseAuth.instance.currentUser;
    if (userLoggedIn == null) {
      userLoggedIn = null;
    } else if (FirebaseAuth.instance.currentUser!.displayName == "User Client") {
      userLoggedIn = "User Client";
    } else if (FirebaseAuth.instance.currentUser!.displayName == "Staff") {
      userLoggedIn = "Staff";
    }

    // else if (FirebaseAuth.instance.currentUser!.displayName != "User Client" &&
    //     FirebaseAuth.instance.currentUser!.email != "admin@gmail.com") {
    //   userLoggedIn = "User Service";
    // }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: context.watch<ThemeManager>().themeMode,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: lightTheme,
      darkTheme: darkTheme,
      home: userLoggedIn == "User Client"
          ? const UserHome()
          : userLoggedIn == "Staff"
              ? const StaffHome()
              : const Onboarding(),
    );
  }
}
