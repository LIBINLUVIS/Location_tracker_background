// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'dart:async';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:vibration/vibration.dart';

// class LocationPage extends StatefulWidget {
//   const LocationPage({Key? key}) : super(key: key);

//   @override
//   State<LocationPage> createState() => _LocationPageState();
// }

// class _LocationPageState extends State<LocationPage> with WidgetsBindingObserver {
//   String? _currentAddress;
//   Position? _currentPosition;


//   @override
//   initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     // Workmanager().registerPeriodicTask(
//     //   "taskTwo",
//     //   "backUp",
//     //   frequency: Duration(minutes: 15),
//     // );

//   }

//     @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state){
//     super.didChangeAppLifecycleState(state);
//     if (state == AppLifecycleState.inactive ||
//         state == AppLifecycleState.detached) return;

//     final isBackground = state == AppLifecycleState.paused;
   
    
//     DatabaseReference ref=FirebaseDatabase.instance.ref("/");

 
//     if(isBackground){
//       Timer mytimer = Timer.periodic(Duration(seconds: 3), (timer) async{
//         _getCurrentPosition();
//         // print(_currentAddress);
//         // print(_currentPosition?.latitude);
//         // print(_currentPosition?.longitude);
//       await ref.update({
//             "location":_currentAddress,
//             "lat":_currentPosition?.latitude,
//             "long":_currentPosition?.longitude
//          }          
//         );
        
//        });

//   }
    
   

//   }
//   Future<bool> _handleLocationPermission() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           content: Text(
//               'Location services are disabled. Please enable the services')));
//       return false;
//     }
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Location permissions are denied')));
//         return false;
//       }
//     }
//     if (permission == LocationPermission.deniedForever) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//           content: Text(
//               'Location permissions are permanently denied, we cannot request permissions.')));
//       return false;
//     }
//     return true;
//   }

//   Future<void> _getCurrentPosition() async {
//     final hasPermission = await _handleLocationPermission();
//     if (!hasPermission) return;
//     await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
//         .then((Position position) {
//       setState(() => _currentPosition = position);
//       _getAddressFromLatLng(_currentPosition!);
//     }).catchError((e) {
//       debugPrint(e);
//     });
//   }

//   Future<void> _getAddressFromLatLng(Position position) async {
//     await placemarkFromCoordinates(
//             _currentPosition!.latitude, _currentPosition!.longitude)
//         .then((List<Placemark> placemarks) {
//       Placemark place = placemarks[0];
//       setState(() {
//         _currentAddress =
//             '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
//       });
//     }).catchError((e) {
//       debugPrint(e);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Location Page")),
//       body: SafeArea(
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text('LAT: ${_currentPosition?.latitude ?? ""}'),
//               Text('LNG: ${_currentPosition?.longitude ?? ""}'),
//               Text('ADDRESS: ${_currentAddress ?? ""}'),
//               const SizedBox(height: 32),
//               ElevatedButton(
//                 onPressed: _getCurrentPosition,
//                 child: const Text("Get Current Location"),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }



//   //   @override
//   // void initState() {
   
//   //   super.initState();
//   //   Workmanager().registerPeriodicTask(
//   //     "taskTwo",
//   //     "backUp",
//   //     frequency: Duration(minutes: 15),
//   //   );
//   // }
// }


