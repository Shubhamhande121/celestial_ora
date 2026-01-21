// ignore_for_file: must_call_super

import 'package:flutter/material.dart';
import 'package:organic_saga/components/custom_back_button.dart';
import 'package:organic_saga/constants/constants.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/account/sub_screens/help_section/sub_screens/issues_facing.dart';

class HelpSection extends StatefulWidget {
  const HelpSection({Key? key}) : super(key: key);

  @override
  State<HelpSection> createState() => _HelpSectionState();
}

class _HelpSectionState extends State<HelpSection> {
  List _helpSectionData = [
    {
      "imageURL": "assets/images/capsicum.png",
      "title": "Delivered On 23 Oct",
      "productName": "Bell Pepper Red",
      "rating": 5
    },
    {
      "imageURL": "assets/images/apple.png",
      "title": "Delivered On 20 Oct",
      "productName": "Red Apple",
      "rating": 4
    },
    {
      "imageURL": "assets/images/sd.png",
      "title": "Delivered On 23 Oct",
      "productName": "Organic Bananas",
      "rating": 5
    },
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: CustomBackButton(),
        backgroundColor: Colors.white,
        title: Text(
          "Help Center",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            width: screenWidth,
            height: screenWidth / 27.6,
          ),
          SizedBox(
            child: Image.asset(
              "assets/images/helpcenter.png",
              height: screenWidth / 3.53,
              width: screenWidth / 3.53,
            ),
            height: screenWidth / 3.53,
            width: screenWidth / 3.53,
          ),
          SizedBox(
            height: screenWidth / 21.79,
            width: screenWidth,
          ),
          Container(
            child: Text(
              "Get quick customer support by select your item",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: screenWidth / 25.875, fontWeight: FontWeight.w600),
            ),
            margin: EdgeInsets.symmetric(horizontal: screenWidth / 9.2),
          ),
          SizedBox(width: screenWidth, height: screenWidth / 17.25),
          Container(
            width: screenWidth,
            height: 1,
            color: Color(0xFFE2E2E2),
          ),
          Expanded(
              child: ListView(
            children: List.generate(
                _helpSectionData.length,
                (index) => IndividualHelpSectionBuilder(
                    screenWidth: screenWidth,
                    title: "${_helpSectionData[index]["title"]}",
                    productName: "${_helpSectionData[index]["productName"]}",
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => IssuesFacing()));
                    },
                    rating: _helpSectionData[index]["rating"],
                    imageURL: "${_helpSectionData[index]["imageURL"]}")),
          ))
        ],
      ),
    );
  }
}

class IndividualHelpSectionBuilder extends StatefulWidget {
  const IndividualHelpSectionBuilder({
    Key? key,
    required this.screenWidth,
    required this.title,
    required this.productName,
    required this.onPressed,
    required this.rating,
    required this.imageURL,
  }) : super(key: key);

  final double screenWidth;
  final String title, productName;
  final VoidCallback onPressed;
  final int rating;
  final String imageURL;

  @override
  _IndividualHelpSectionBuilderState createState() =>
      _IndividualHelpSectionBuilderState();
}

class _IndividualHelpSectionBuilderState
    extends State<IndividualHelpSectionBuilder>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPressed,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: widget.screenWidth,
          child: Column(
            children: [
              Container(
                child: Row(
                  children: [
                    SizedBox(
                      child: Image.asset(
                        "${widget.imageURL}",
                        height: widget.screenWidth / 6.399,
                        width: widget.screenWidth / 4.01,
                      ),
                      height: widget.screenWidth / 6.399,
                      width: widget.screenWidth / 4.01,
                    ),
                    SizedBox(width: widget.screenWidth / 31.84),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${widget.title}",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: widget.screenWidth / 25.875),
                          ),
                          Text(
                            "${widget.productName}",
                            style: TextStyle(
                                fontSize: widget.screenWidth / 25.875,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: widget.screenWidth / 41.4),
                          Row(
                            children: List.generate(
                                5,
                                (index) => Icon(
                                      index + 1 <= widget.rating
                                          ? Icons.star
                                          : Icons.star_outline,
                                      color: secondaryColor,

                                    )),
                          )
                        ]),
                    Spacer(),
                    Icon(Icons.keyboard_arrow_right),
                  ],
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: widget.screenWidth / 16.38,
                    vertical: widget.screenWidth / 17.25),
              ),
              Container(
                width: widget.screenWidth,
                margin: EdgeInsets.symmetric(
                  horizontal: widget.screenWidth / 16.38,
                ),
                height: 1,
                color: Color(0xFFE2E2E2),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
