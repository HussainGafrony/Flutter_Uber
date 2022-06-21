import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:test/screen/map_screen.dart';

class SearchScreen extends StatefulWidget {
  static String apikey = 'apikey';

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final startPoint = TextEditingController();
  final endPoint = TextEditingController();

  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictins = [];
  DetailsResult? startPosition;
  DetailsResult? endtPosition;
  late FocusNode startFocusNode;
  late FocusNode endFocusNode;

  void initState() {
    super.initState();
    googlePlace = GooglePlace(SearchScreen.apikey);
    startFocusNode = FocusNode();
    endFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    startFocusNode.dispose();
    endFocusNode.dispose();
    super.dispose();
  }

  Timer? debouns;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              focusNode: startFocusNode,
              controller: startPoint,
              autofocus: false,
              decoration: InputDecoration(
                  hintText: 'Start Point',
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  border: InputBorder.none,
                  suffixIcon: startPoint.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              predictins = [];
                              startPoint.clear();
                            });
                          },
                          icon: Icon(Icons.clear_outlined))
                      : null),
              onChanged: (value) {
                if (debouns?.isActive ?? false) debouns!.cancel();
                debouns = Timer(Duration(milliseconds: 500), (() {
                  if (value.isNotEmpty) {
                    autoComplate(value);
                  } else {
                    setState(() {
                      startPosition = null;
                      predictins = [];
                    });
                  }
                }));
              },
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              enabled: startPoint.text.isNotEmpty && startPosition != null,
              focusNode: endFocusNode,
              controller: endPoint,
              autofocus: false,
              decoration: InputDecoration(
                  hintText: 'End Point',
                  filled: true,
                  fillColor: Colors.grey.shade300,
                  border: InputBorder.none,
                  suffixIcon: endPoint.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              predictins = [];
                              endPoint.clear();
                            });
                          },
                          icon: Icon(Icons.clear_outlined))
                      : null),
              onChanged: (value) {
                if (debouns?.isActive ?? false) debouns!.cancel();
                debouns = Timer(Duration(milliseconds: 500), (() {
                  if (value.isNotEmpty) {
                    autoComplate(value);
                  } else {
                    setState(() {
                      endtPosition = null;
                      predictins = [];
                    });
                  }
                }));
              },
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: predictins.length,
              itemBuilder: ((context, index) {
                return ListTile(
                  title: Text(predictins[index].description.toString()),
                  leading: CircleAvatar(
                    child: Icon(Icons.pin_drop),
                  ),
                  onTap: () async {
                    final placeId = predictins[index].placeId;
                    final details = await googlePlace.details.get(placeId!);
                    if (details != null && details.result != null && mounted) {
                      if (startFocusNode.hasFocus) {
                        setState(() {
                          startPosition = details.result;
                          startPoint.text = details.result!.name!;
                          predictins = [];
                        });
                      } else {
                        setState(() {
                          endtPosition = details.result;
                          endPoint.text = details.result!.name!;
                          predictins = [];
                        });
                      }
                      if (startPosition != null && endtPosition != null) {
                        print('navigate');
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MapScreen(
                                      startPosition: startPosition,
                                      endtPosition: endtPosition,
                                    )));
                      }
                    }
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  autoComplate(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictins = result.predictions!;
      });
      print(result.predictions!.first.description);
    } else {}
  }
}
