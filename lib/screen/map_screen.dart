import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:test/screen/search.dart';
import 'package:test/widgets/map_utils.dart';

class MapScreen extends StatefulWidget {
  final DetailsResult? startPosition;
  final DetailsResult? endtPosition;
  MapScreen({required this.startPosition, required this.endtPosition});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List cars = [
    {'id': 0, 'name': 'Select a Ride', 'price': 0.0},
    {'id': 1, 'name': 'UberGo', 'price': 230.0},
    {'id': 2, 'name': 'Go Sedan', 'price': 300.0},
    {'id': 3, 'name': 'UberXL', 'price': 500.0},
    {'id': 4, 'name': 'UberAuto', 'price': 140.0},
  ];

  late CameraPosition cameraPosition;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  ScrollController? scrollController;
  int selectedCardId = 1;
  @override
  void initState() {
    cameraPosition = CameraPosition(
        target: LatLng(widget.startPosition!.geometry!.location!.lat!,
            widget.startPosition!.geometry!.location!.lng!),
        zoom: 14);
    // TODO: implement initState
    super.initState();
  }

  Widget build(BuildContext context) {
    Set<Marker> marker = {
      Marker(
          markerId: MarkerId('start'),
          position: LatLng(widget.startPosition!.geometry!.location!.lat!,
              widget.startPosition!.geometry!.location!.lng!)),
      Marker(
          markerId: MarkerId('end'),
          position: LatLng(widget.endtPosition!.geometry!.location!.lat!,
              widget.endtPosition!.geometry!.location!.lng!)),
    };

    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          LayoutBuilder(
              builder: (BuildContext context, BoxConstraints boxConstraints) {
            return SizedBox(
              height: boxConstraints.maxHeight / 2,
              child: GoogleMap(
                initialCameraPosition: cameraPosition,
                markers: Set.from(marker),
                onMapCreated: (GoogleMapController controller) {
                  Future.delayed(Duration(milliseconds: 200), () {
                    controller.animateCamera(
                      CameraUpdate.newLatLngBounds(
                          MapUtils.boundsFromLatLngList(
                              marker.map((loc) => loc.position).toList()),
                          1),
                    );
                    getPolyline();
                  });
                },
                polylines: Set<Polyline>.of(polylines.values),
              ),
            );
          }),
          DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.5,
              snapSizes: [0.5, 1],
              snap: true,
              builder: ((context, scrollController) {
                return Container(
                  color: Colors.white,
                  child: ListView.builder(
                      physics: ClampingScrollPhysics(),
                      controller: scrollController,
                      itemCount: cars.length,
                      itemBuilder: ((context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: EdgeInsets.all(8),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 50,
                                  child: Divider(
                                    thickness: 5,
                                  ),
                                ),
                                Text('Choose a tripe or swipe up for more'),
                              ],
                            ),
                          );
                        }
                        return Card(
                          elevation: 0,
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            contentPadding: EdgeInsets.all(10),
                            leading: Icon(Icons.car_rental),
                            title: Text(cars[index]['name']),
                            trailing: Text(cars[index]['price'].toString()),
                            selected: selectedCardId == cars[index]['id'],
                            selectedTileColor: Colors.teal.shade100,
                            onTap: () {
                              setState(() {
                                selectedCardId = cars[index]['id'];
                              });
                            },
                          ),
                        );
                      })),
                );
              }))
        ],
      ),
    );
  }

  _addPolyLine() {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.black,
        points: polylineCoordinates,
        width: 2);
    polylines[id] = polyline;
    setState(() {});
  }

  getPolyline() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        SearchScreen.apikey,
        PointLatLng(widget.startPosition!.geometry!.location!.lat!,
            widget.startPosition!.geometry!.location!.lng!),
        PointLatLng(widget.endtPosition!.geometry!.location!.lat!,
            widget.endtPosition!.geometry!.location!.lng!),
        travelMode: TravelMode.driving);

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _addPolyLine();
  }
}
