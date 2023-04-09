import 'package:flutter/material.dart';
import 'location_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workmanager/workmanager.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:vibration/vibration.dart';



DatabaseReference ref=FirebaseDatabase.instance.ref("/");
void callbackDispatcher(){
  Workmanager().executeTask((taskName, inputData) async{
  
  await _LocationPageState()._getCurrentPosition();
  // print("heyy");
  // print(_LocationPageState()._currentAddress);
  // print(_LocationPageState()._currentPosition?.latitude);
  // print(_LocationPageState()._currentPosition?.longitude);
  final location=_LocationPageState()._currentAddress;
  final long=_LocationPageState()._currentPosition?.longitude;
  final lat=_LocationPageState()._currentPosition?.latitude;

  await ref.update({
    "location":location,
    "lat":lat,
    "long":long
    });
    return Future.value(true);
  });
}


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher);
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Location testing',
      debugShowCheckedModeBanner: false,
      home: LocationPage(),
    );
  }
}


class LocationPage extends StatefulWidget {
  const LocationPage({Key? key}) : super(key: key);

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> with WidgetsBindingObserver {
  String? _currentAddress;
  Position? _currentPosition;


  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Workmanager().registerPeriodicTask(
      "taskTwo",
      "backUp",
      frequency: Duration(minutes: 15)
    );

  }

    @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) return;

    final isBackground = state == AppLifecycleState.paused;
   
    
    DatabaseReference ref=FirebaseDatabase.instance.ref("/");

 
    if(isBackground){
      Timer mytimer = Timer.periodic(Duration(seconds: 5), (timer) async{
        _getCurrentPosition();
        // print(_currentAddress);
        // print(_currentPosition?.latitude);
        // print(_currentPosition?.longitude);
      await ref.update({
            "location":_currentAddress,
            "lat":_currentPosition?.latitude,
            "long":_currentPosition?.longitude
         }          
        );
        
       });

  }
    
   

  }
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }




  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  void _cancelbackground(){
    Workmanager().cancelByUniqueName("taskTwo");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Location Page")),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('LAT: ${_currentPosition?.latitude ?? ""}'),
              Text('LNG: ${_currentPosition?.longitude ?? ""}'),
              Text('ADDRESS: ${_currentAddress ?? ""}'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _getCurrentPosition,
                child: const Text("Get Current Location"),
              ),
              ElevatedButton(
                onPressed: _cancelbackground,
                child: const Text("Cancel background task"),
              ),
            ],
          ),
        ),
      ),
    );
  }

}