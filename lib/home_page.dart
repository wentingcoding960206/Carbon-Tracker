import 'package:flutter/material.dart';
import 'semi_circle_menu.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState(){
    return _HomeScreenState();
  } 
}

class _HomeScreenState extends State<HomeScreen>{
  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
            height: 860,
            width: double.infinity,
            child: Text(
              'map',
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
              ),
            )
    //          GoogleMap(
    //          initialCameraPosition: CameraPosition(
    //          target: LatLng(25.033964, 121.564468),
    //          zoom: 14,
    //          ),
    //          myLocationEnabled: true,
    //          myLocationButtonEnabled: false,
    //          onMapCreated: (GoogleMapController controller) {
    //   },
    // ),
  ),
),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: IconButton(
                  icon : Icon(Icons.person_2_outlined),
                  iconSize: 40,
                  onPressed: () {},
                  ),
              ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child:Padding(
              padding: EdgeInsets.only(top: 90),
              child: IconButton(
                  icon : Icon(Icons.camera_alt_outlined),
                  iconSize: 40,
                  onPressed: () {},
                  ),
              ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.only(top: 20),
              child: IconButton(
                  icon : Icon(Icons.edit),
                  iconSize: 40,
                  onPressed: () {},
                  ),
              ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 100,
              width: double.infinity,
              color: Colors.green.shade300,
            ),
          ),
          Positioned(
            bottom: 90,
            left: MediaQuery.of(context).size.width / 2 - 92,
            child: SemiCircleMenu(
              icons: [
                Icons.flight,
                Icons.directions_car,
                Icons.directions_walk,
                Icons.directions_bike,
                Icons.two_wheeler,
                Icons.train,
                Icons.subway,
                ],
              radius: 80,
              onItemTap: (index) {
              print('Tapped on $index');
              },
            ),
          ),
          Positioned(
            bottom: 30,
            left: MediaQuery.of(context).size.width / 2 - 70,
            child: GestureDetector(
              onTap: () {},
              child: CircleAvatar(
              radius: 70,
              backgroundColor: Colors.black,
              child: Icon(
                Icons.navigation_sharp,
                color: Colors.white,
                size: 70,
                ),
              ),
            ),
            ),
          Positioned(
                bottom: 20,
                left: MediaQuery.of(context).size.width / 5-50,
                child: IconButton(
                  onPressed: () {}, 
                  icon: Icon(Icons.access_time_outlined),
                  iconSize: 50,
            ),
          ),
          Positioned(
                bottom: 20,
                right: MediaQuery.of(context).size.width / 5 - 40,
                child: Material(
                  color: Colors.transparent,
                  elevation: 0,
                  shape: CircleBorder(),
                  child: InkWell(
                  onTap: () {},
                  splashColor: Colors.green.shade300.withValues(alpha: 0.6),
                  highlightColor: Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent, 
                    radius: 30,
                    backgroundImage: AssetImage("assets/leaderboard.png"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}