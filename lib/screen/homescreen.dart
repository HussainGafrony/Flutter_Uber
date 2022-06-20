import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/screen/search.dart';
import 'package:test/widgets/customContanire.dart';
import 'package:test/widgets/customContanireSmall.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Set<Marker> marker = Set<Marker>();
  Set<Polygon> polygon = Set<Polygon>();

  static const initialCameraPosition =
      CameraPosition(target: LatLng(37.0588348, 37.3451175), zoom: 11);
  GoogleMapController? googleMapController;
  TextEditingController? searchController;
  @override
  void dispose() {
    googleMapController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('MapScreen'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: CustomContanire(
                    img: 'assets/images/suv.png',
                    title: 'Ride',
                  )),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: CustomContanire(
                    img: 'assets/images/box.png',
                    title: 'Package',
                  )),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                      child: CustomContanireSmall(
                    img: 'assets/images/car.png',
                    title: 'Car',
                  )),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: CustomContanireSmall(
                    img: 'assets/images/train.png',
                    title: 'Train',
                  )),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: CustomContanireSmall(
                    img: 'assets/images/bus.png',
                    title: 'Bus',
                  )),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: CustomContanireSmall(
                    img: 'assets/images/car.png',
                    title: 'Transit',
                  )),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                onTap: (() {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchScreen(),
                        fullscreenDialog: true,
                      ));
                }),
                autofocus: false,
                showCursor: false,
                decoration: InputDecoration(
                  hintText: 'Where To?',
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            googleMapController!.animateCamera(
                CameraUpdate.newCameraPosition(initialCameraPosition));
          },
          backgroundColor: Theme.of(context).backgroundColor,
          foregroundColor: Colors.black,
          child: Icon(
            Icons.center_focus_strong,
            size: 35,
          ),
        ));
  }
}
