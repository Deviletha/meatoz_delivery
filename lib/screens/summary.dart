import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Config/ApiHelper.dart';
import '../components/appbar_text.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

import 'Login_page.dart';
import 'details_page.dart';

class Summary extends StatefulWidget {
  const Summary({Key? key}) : super(key: key);

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  String? base = "https://meatoz.in/basicapi/public/";
  String? UID;
  bool isLoading = true;
  String? startDate;
  String? endDate;

  String? data;
  Map? deliveryList;
  Map? deliveryList1;
  List? finalDeliveryList;
  List? deliveredList;
  List? notDeliveredList;
  List? cancelledList;
  bool isLoggedIn = true;

  double totaltip = 0;
  String? TOTALTIP;

  @override
  void initState() {
    checkUser();
    super.initState();
  }

  Future<void> checkUser() async {
    final prefs = await SharedPreferences.getInstance();
    UID = prefs.getString("UID");
    setState(() {
      isLoggedIn = UID != null;
      print(UID);
    });
    if (isLoggedIn) {
      apiForDeliveryDetails();
    }
  }

  apiForDeliveryDetails() async {


    var response =
        await ApiHelper().post(endpoint: "common/getEmployeeAllSummary", body: {
      "offset": "0",
      "pageLimit": "100",
      "employeeid": UID,
      "fromDate": startDate,
      "toDate": endDate
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
          deliveredList = finalDeliveryList![0]["Delivered"];
          notDeliveredList = finalDeliveryList![0]["Not Delivered"];
          cancelledList = finalDeliveryList![0]["Cancelled"];
          print(cancelledList!);

          if (deliveredList != null && deliveredList!.isNotEmpty) {
            for (int i = 0; i < deliveredList!.length; i++) {
              int price = deliveredList![i]["tip"];
              totaltip = totaltip + price;
            }
          }
          TOTALTIP = totaltip.toString();

        }
      });
    } else {
      debugPrint('api failed:');
    }
  }

  DateTime _dateStrtTime = DateTime.now();

  void _showDatePickerStart() {
    showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2010),
        lastDate: DateTime(2025)).then((value) {
          setState(() {
            _dateStrtTime = value!;
          });
    });
  }

  DateTime _dateEndTime = DateTime.now();

  void _showDatePickerEnd() {
    showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2010),
        lastDate: DateTime(2025)).then((value) {
      setState(() {
        _dateEndTime = value!;
      });
    });
  }

  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            gapPadding: 20,
          ),
          title: Text('Logout'),
          content: Text('Do you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Logout'),
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

  Widget _buildShimmerList() {
    return SizedBox(
      height: 200, // Adjust the height as needed
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: ListView.builder(
          itemCount: 5, // Number of shimmering items
          itemBuilder: (_, __) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 15,
                        color: Colors.white,
                      ),
                      SizedBox(height: 5),
                      Container(
                        width: 150,
                        height: 15,
                        color: Colors.white,
                      ),
                      SizedBox(height: 5),
                      Container(
                        width: 100,
                        height: 15,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    startDate =  DateFormat('yyyy-MM-dd').format(_dateStrtTime).toString();
    endDate = DateFormat('yyyy-MM-dd').format(_dateEndTime).toString();

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
            SizedBox(
              height: 10,
            ), isLoggedIn
                ?
            isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.teal.shade900,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade300)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(startDate.toString()),
                              IconButton(
                                  onPressed: _showDatePickerStart,
                                  icon: Icon(Icons.date_range_outlined)),
                              Text(endDate.toString()),
                              IconButton(
                                  onPressed: _showDatePickerEnd,
                                  icon: Icon(Icons.date_range_outlined)),
                              ElevatedButton(
                                onPressed: () {
                                  apiForDeliveryDetails();
                                },
                                child: Text("Filter"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade400,
                                  shadowColor: Colors.red.shade100,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.shade300)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              "Total Tip : Rs ${TOTALTIP!}",
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: ExpansionTile(
                              title: Text(
                                "Delivered (${deliveredList?.length ?? 0})",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              children: [
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: deliveredList == null
                                      ? _buildShimmerList()
                                      : ListView.builder(
                                          physics: ScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: deliveredList?.length ?? 0,
                                          itemBuilder: (context, index) =>
                                              getDelivered(index),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: ExpansionTile(
                              title: Text(
                                "Not Delivered(${notDeliveredList?.length ?? 0})",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              children: [
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: notDeliveredList == null
                                      ? _buildShimmerList()
                                      : ListView.builder(
                                          physics: ScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount:
                                              notDeliveredList?.length ?? 0,
                                          itemBuilder: (context, index) =>
                                              getNotDelivered(index),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: ExpansionTile(
                              title: Text(
                                "Cancelled(${cancelledList?.length ?? 0})",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              children: [
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: cancelledList == null
                                      ? _buildShimmerList()
                                      : ListView.builder(
                                          physics: ScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: cancelledList?.length ?? 0,
                                          itemBuilder: (context, index) =>
                                              getCancelled(index),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                : Container(
              height: 400,
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.asset(
                      "assets/logo1.png",
                      height: 50,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[900],
                        shadowColor: Colors.teal[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(10),
                            topLeft: Radius.circular(10),
                          ),
                        ),
                      ),
                      child: Text("Please LogIn"),
                    ),
                  ],
              ),
                ),
          ],
        ),
      ),
    );
  }

  Widget getDelivered(int index) {
    if (deliveredList == null || index >= deliveredList!.length) {
      return Container(); // Return an empty container when data is null or index is out of bounds
    }
    var image = base! + deliveredList![index]["image"].toString();
    var price = "Rs.${deliveredList![index]["total"]}";
    var customer = "Customer :${deliveredList![index]["customer_name"]}";
    var address = "Address :${deliveredList![index]["customer_address"]}";
    var phone = "Phone :${deliveredList![index]["customer_phone"]}";
    var order = "Order :${deliveredList![index]["cartName"]}";
    return InkWell(
          onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetails(
                id: deliveredList![index]["id"].toString()
            ),
          ),
        );
      },
      child: Card(
          color: Colors.grey.shade50,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  clipBehavior: Clip.antiAlias,
                  width: 150,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
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
                      deliveredList == null
                          ? Text("null data")
                          : Text(
                              customer,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black),
                            ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        address,
                        maxLines: 3,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        phone,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        order,
                        maxLines: 4,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        height: 10,
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
          )),
    );
  }

  Widget getNotDelivered(int index) {
    if (notDeliveredList == null || index >= notDeliveredList!.length) {
      return Container(); // Return an empty container when data is null or index is out of bounds
    }
    var image = base! + notDeliveredList![index]["image"].toString();
    var price = "Rs.${notDeliveredList![index]["total"]}";
    var customer = "Customer :${notDeliveredList![index]["customer_name"]}";
    var address = "Address :${notDeliveredList![index]["customer_address"]}";
    var phone = "Phone :${notDeliveredList![index]["customer_phone"]}";
    var order = "Order :${notDeliveredList![index]["cartName"]}";
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetails(
                id: notDeliveredList![index]["id"].toString()
            ),
          ),
        );
      },
      child: Card(
          color: Colors.grey.shade50,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  clipBehavior: Clip.antiAlias,
                  width: 150,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
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
                      deliveredList == null
                          ? Text("null data")
                          : Text(
                              customer,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black),
                            ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        address,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        phone,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        order,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        height: 10,
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
          )),
    );
  }

  Widget getCancelled(int index) {
    if (cancelledList == null || index >= cancelledList!.length) {
      return Container(); // Return an empty container when data is null or index is out of bounds
    }
    var image = base! + cancelledList![index]["image"].toString();
    var price = "Rs.${cancelledList![index]["total"]}";
    var customer = "Customer :${cancelledList![index]["customer_name"]}";
    var address = "Address :${cancelledList![index]["customer_address"]}";
    var phone = "Phone :${cancelledList![index]["customer_phone"]}";
    var order = "Order :${cancelledList![index]["cartName"]}";
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetails(
                id: cancelledList![index]["id"].toString()
            ),
          ),
        );
      },
      child: Card(
          color: Colors.grey.shade50,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  clipBehavior: Clip.antiAlias,
                  width: 150,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
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
                      deliveredList == null
                          ? Text("null data")
                          : Text(
                              customer,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black),
                            ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        address,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        phone,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        order,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        height: 10,
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
          )),
    );
  }
}
