import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:object_detection_app/view/object_detection_screen.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show SystemChannels, rootBundle;

/// A screen that displays a list of items and allows users to search and select an item for object detection.
class ItemListScreen extends StatefulWidget {
  const ItemListScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> with WidgetsBindingObserver {
  List<String> itemList = [];
  bool isKeyboardOpen = false; //checking for keyboard is opened or not

  /// Loads the content of 'labelmap.txt' from the assets.
  Future<String> loadAsset() async {
    return await rootBundle.loadString('assets/object_files/labelmap.txt');
  }

  /// Retrieves and processes the data from 'labelmap.txt'.
  void getData() async {
    String itemString = await loadAsset();
    List<dynamic> itemData = itemString
        .split("\n")
        .map((x) => x.trim())
        .where((element) => element.isNotEmpty)
        .toList();
    for (String item in itemData) {
      if (!item.contains("???")) {
        itemList.add(item);
      }
      continue;
    }
    setState(() {
      itemList;
    });
  }

  @override
  void initState() {
    /// Called when this state object is inserted into the widget tree.
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getData();
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    setState(() {
      isKeyboardOpen = bottomInset > 0;/// greater than zero when the keyboard is open and zero when it is closed
    });
  }


  List<String> filteredItems = [];
  String _query = '';

  /// Filters the item list based on the search query.
  void search(String query) {
    setState(() {
      _query = query;

      filteredItems = itemList
          .where(
            (item) => item.toLowerCase().contains(query.toLowerCase()),
      )
          .toList();
    });
  }

  /// Generates a widget list for displaying items.
  Widget itemWidgetList(List<String> itemList) {
    return Container(
      color: Colors.white,
      child: GridView.count(
        crossAxisCount: 2,
        children: List.generate(itemList.length, (index) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 6,
            child: Card(
              color: Colors.blueGrey.withOpacity(0.85),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    itemList[index],
                    maxLines: 2,
                    style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 5, horizontal: 15),
                    child: ElevatedButton(
                      onPressed: () async {
                        //initialize camera
                        WidgetsFlutterBinding.ensureInitialized();
                        final cameras = await availableCameras();
                        if(isKeyboardOpen){
                          FocusScope.of(context).unfocus();
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                ObjectDetectionScreen(
                                  cameras: cameras,
                                  itemName: itemList[index].toString(),
                                ),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Get started',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.blueGrey),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.blueGrey,
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              if(isKeyboardOpen){
                FocusScope.of(context).unfocus(); /// if keyboard is opened, it will close the keyboard
              }else
                {
                  Platform.isIOS ? exit(0)
                      : SystemChannels.platform.invokeMethod('SystemNavigator.pop'); /// exit app based on the platform
                }

            }
          ),
        ),
        title: TextField(
          style: const TextStyle(
            color: Colors.black,
          ),
          onChanged: (value) {
            search(value); /// search item
          },
          decoration: const InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.black),
            fillColor: Colors.black,
            prefixIcon: Icon(
              Icons.search,
              color: Colors.black,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: filteredItems.isNotEmpty || _query.isNotEmpty /// Showing data based on the search,
      /// if searched item available it will show the item in filtered list otherwise No Results Found,
      /// itemList will show the full items
          ? filteredItems.isEmpty
          ? const Center(
        child: Text(
          'No Results Found',
          style: TextStyle(fontSize: 18),
        ),
      )
          : itemWidgetList(filteredItems)
          : itemWidgetList(itemList),
    );
  }
}