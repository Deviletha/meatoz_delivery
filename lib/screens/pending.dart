import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:meatoz_delivery/components/appbar_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Config/ApiHelper.dart';
import 'details_page.dart';

class Pending extends StatefulWidget {
  const Pending({Key? key}) : super(key: key);

  @override
  State<Pending> createState() => _PendingState();
}

class _PendingState extends State<Pending> {
  String? base = "https://meatoz.in/basicapi/public/";
  String? UID;
  bool isLoading = false;
  String? data;
  Map? deliveryList;
  Map? deliveryList1;
  List? finalDeliveryList;
  String? time;
  String? ORDERID;

  String? STATUS;
  final noteController = TextEditingController();

  @override
  void initState() {
    checkUser();
    super.initState();
  }

  Future<void> checkUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      UID = prefs.getString("UID");
      print(UID);
    });
    // apiForOrderDetails();
  }

  apiForDeliveryStatus(String STATUS) async {
    DateTime currentTime = DateTime.now();
    var response = await ApiHelper().post(
      endpoint: "updatestatus/deliverystatus",
      body: {
        "orderId": ORDERID,
        "time": currentTime.toUtc().toIso8601String(), // Convert DateTime to ISO 8601 format
        "deliverynote": noteController.text.toString(),
        "status": STATUS
      },
    ).catchError((err) {});

    if (response != null) {
      setState(() {
        debugPrint('status api successful:');
        print(response);
      });
    } else {
      debugPrint('status api failed:');
    }
  }

  apiForOrderDetails() async {
    setState(() {
      isLoading = true;
    });

    var response =
        await ApiHelper().post(endpoint: "common/getEmployeeOrders", body: {
      "offset": "0",
      "pageLimit": "100",
      "employeeid": UID,
    }).catchError((err) {});

    setState(() {
      isLoading = false;
    });

    if (response != null) {
      setState(() {
        debugPrint('get products api successful:');
        data = response.toString();
        deliveryList = jsonDecode(response);
        deliveryList1 = deliveryList!["data"];
        if (deliveryList != null && deliveryList1 != null) {
          finalDeliveryList = deliveryList1!["pageData"];
        }
      });
    } else {
      debugPrint('api failed:');
    }
  }

  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20), gapPadding: 20),
          title: Text('Logout'),
          content: Text('Do you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Logout',
              ),
              onPressed: () async {
                Navigator.of(context).pop();

                // Clear the user session data
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove("UID");
                Fluttertoast.showToast(
                  msg: "Logged out",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.SNACKBAR,
                  timeInSecForIosWeb: 1,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showOrderDetailsBottomSheet(int index1) {
    var image = base! + finalDeliveryList![index1]["image"].toString();
    var price = "Rs.${finalDeliveryList![index1]["total"]}";
    var customer = "Customer: ${finalDeliveryList![index1]["customer_name"]}";
    var address = "Address: ${finalDeliveryList![index1]["customer_address"]}";
    var phone = "Phone: ${finalDeliveryList![index1]["customer_phone"]}";
    var order = "Order: ${finalDeliveryList![index1]["cartName"]}";
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        clipBehavior: Clip.antiAlias,
                        width: 150,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                          ),
                        ),
                        // Image border// Image radius
                        child: CachedNetworkImage(
                          imageUrl: image,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage("assets/noItem.png"))),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            finalDeliveryList == null
                                ? Text("null data")
                                : Text(
                              customer,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              address,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              phone,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              order,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              price,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  TextFormField(
                    cursorColor: Colors.teal[900],
                    controller: noteController,
                    obscuringCharacter: "*",
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Delivery Note",
                      focusColor: Colors.grey,
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // STATUS = "Cancelled";
                          // print("Status "+ STATUS!);
                          apiForDeliveryStatus("Cancelled");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade500,
                          shadowColor: Colors.red.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text("Cancelled"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // STATUS = "Not Delivered";
                          apiForDeliveryStatus("Not Delivered");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade500,
                          shadowColor: Colors.orange.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text("Not Delivered"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // STATUS = "Delivered";
                          // print("Status "+ STATUS!);
                          apiForDeliveryStatus("Delivered");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade500,
                          shadowColor: Colors.green.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text("Delivered"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
            colors: [
              Colors.grey.shade400,
              Colors.grey.shade200,
              Colors.grey.shade50,
              Colors.grey.shade200,
              Colors.grey.shade400,
            ],
          ),
        ),
        child: ListView(
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                  ),
                  color: Colors.black87),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppText(text: "DELIVERY APP"),
                  IconButton(
                      onPressed: () {
                        _showLogoutConfirmationDialog();
                      },
                      icon: Icon(
                        CupertinoIcons.power,
                        color: Colors.white,
                      ))
                ],
              ),
            ),
            ListView.builder(
              physics: ScrollPhysics(),
              shrinkWrap: true,
              itemCount: finalDeliveryList?.length ?? 0,
              itemBuilder: (context, index) {
                // Filter items with "status" = 3
                if (finalDeliveryList![index]["status"] == 3) {
                  return getDetails(index);
                } else {
                  // Return an empty container for items with other "status" values
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget getDetails(int index) {
    if (finalDeliveryList == null || index >= finalDeliveryList!.length) {
      return Container(); // Return an empty container when data is null or index is out of bounds
    }
    var image = base! + finalDeliveryList![index]["image"].toString();
    var price = "Rs.${finalDeliveryList![index]["total"]}";
    var customer = "Customer: ${finalDeliveryList![index]["customer_name"]}";
    var address = "Address: ${finalDeliveryList![index]["customer_address"]}";
    var phone = "Phone: ${finalDeliveryList![index]["customer_phone"]}";
    var order = "Order: ${finalDeliveryList![index]["cartName"]}";
    var tip = "Tip Rs.${finalDeliveryList![index]["tip"]}";
    var phoneCall = finalDeliveryList![index]["customer_phone"].toString();
    var deliveryNote =
        "Delivery note: ${finalDeliveryList![index]["delivery_note"]}";
    var deliveryTime =
        "Delivery with in: ${finalDeliveryList![index]["delivery_time"]}";
    var statusNote = finalDeliveryList![index]["status_note"];

    return Card(
        color: Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  ///showBottomsheet function here
                  ORDERID = finalDeliveryList![index]["id"].toString();
                  _showOrderDetailsBottomSheet(index); // Show the bottom sheet
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          clipBehavior: Clip.antiAlias,
                          width: 150,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(15),
                              topLeft: Radius.circular(15),
                            ),
                          ),
                          child: Text(
                            statusNote,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Container(
                          clipBehavior: Clip.antiAlias,
                          width: 150,
                          height: 110,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(15),
                              bottomLeft: Radius.circular(15),
                            ),
                          ),
                          // Image border// Image radius
                          child: CachedNetworkImage(
                            imageUrl: image,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[300],
                            ),
                            errorWidget: (context, url, error) => Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage("assets/noItem.png"))),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          finalDeliveryList == null
                              ? Text("null data")
                              : Text(
                                  customer,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.black),
                                ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            address,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            phone,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            deliveryNote,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            order,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            deliveryTime,
                            style: TextStyle(
                              color: Colors.blueGrey.shade500,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                price,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.red),
                              ),
                              Text(
                                tip,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.orange),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                        onPressed: () {
                          launch("tel: +91$phoneCall");
                        },
                        child: Row(
                          children: [
                            Text(
                              "Call",
                              style: TextStyle(color: Colors.black),
                            ),
                            Icon(
                              Icons.call,
                              size: 18,
                              color: Colors.green,
                            )
                          ],
                        )),
                    TextButton(
                      onPressed: () {
                        // Extract latitude and longitude from finalDeliveryList
                        double latitude =
                            double.parse(finalDeliveryList![index]["latitude"]);
                        double longitude = double.parse(
                            finalDeliveryList![index]["longitude"]);

                        // Launch the map application with the provided latitude and longitude
                        String mapUrl =
                            "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
                        launch(mapUrl);
                      },
                      child: Row(
                        children: [
                          Text(
                            "Location",
                            style: TextStyle(color: Colors.black),
                          ),
                          Icon(
                            Icons.location_on,
                            size: 18,
                            color: Colors.indigo,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetails(
                                  id: finalDeliveryList![index]["id"]
                                      .toString()),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              "Details",
                              style: TextStyle(color: Colors.black),
                            ),
                            Icon(
                              Icons.sticky_note_2_outlined,
                              size: 18,
                              color: Colors.red,
                            )
                          ],
                        )),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
