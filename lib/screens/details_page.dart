import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../Components/appbar_text.dart';
import '../Config/ApiHelper.dart';

class OrderDetails extends StatefulWidget {
  final String id;

  const OrderDetails({Key? key, required this.id}) : super(key: key);

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  String? base = "https://meatoz.in/basicapi/public/";
  bool isLoading = false;

  String? data;
  Map? orderList;
  Map? orderList1;
  List? finalOrderList;

  @override
  void initState() {
    apiForOrderDetails();
    super.initState();
  }

  apiForOrderDetails() async {
    setState(() {
      isLoading = true;
    });

    var response =
    await ApiHelper().post(endpoint: "common/getEmployeeOrderDetails", body: {
      "offset": "0",
      "pageLimit": "100",
      "orderid": widget.id,
    }).catchError((err) {});

    setState(() {
      isLoading = false;
    });

    if (response != null) {
      setState(() {
        debugPrint('get products api successful:');
        data = response.toString();
        orderList = jsonDecode(response);
        orderList1 = orderList!["data"];
        if (orderList != null && orderList1 != null) {
          finalOrderList = orderList1!["pageData"];
          print(finalOrderList);
        }
      });
    } else {
      debugPrint('api failed:');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText(text:
        "ORDER HISTORY",
        ),
      ),
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
                ])
        ),
        child: ListView.builder(
          physics: ScrollPhysics(),
          shrinkWrap: true,
          itemCount: finalOrderList == null ? 0 : finalOrderList?.length,
          itemBuilder: (context, index) => getOrderList(index),
        ),
      ),

    );
  }

  Widget getOrderList(int index) {
    var image = base! + finalOrderList![index]["image"].toString();
    var price = "Rs.${finalOrderList![index]["price"]}";
    var quantity = "QTY: ${finalOrderList![index]["quantity"]}";
    var name = finalOrderList![index]["product"];

    return Card(
        color: Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                clipBehavior: Clip.antiAlias,
                width:150,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: CachedNetworkImage(
                  imageUrl: image,
                  placeholder: (context, url) =>
                      Container(
                        color: Colors.grey[300],
                      ),
                  errorWidget: (context, url, error) =>
                      Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage("assets/noItem.png"))),
                      ),
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  orderList == null
                      ? Text("null data")
                      : Text(
                    name,
                    maxLines: 3,
                    style:  TextStyle(fontSize: 15),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    quantity,
                    style:  TextStyle(color: Colors.grey.shade600),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    price,
                    style:  TextStyle(
                        fontSize: 18,
                        color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
