import 'package:flutter/material.dart';
import 'package:organic_saga/components/custom_back_button.dart';
import 'package:organic_saga/constants/constants.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/account/sub_screens/help_section/sub_screens/faq_detail.dart';

class IssuesFacing extends StatefulWidget {
  const IssuesFacing({Key? key}) : super(key: key);

  @override
  State<IssuesFacing> createState() => _IssuesFacingState();
}

class _IssuesFacingState extends State<IssuesFacing> {
  List _faqsData = [
    {"title": "I want to track my order?", "subtitle": "check order status"},
    {
      "title": "I want to manage my order?",
      "subtitle": "cancel my order, change  delivery address"
    },
    {
      "title": "I want to help with refunds & returns",
      "subtitle": "Manage track returns"
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
          "FAQ's",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            child: Row(
              children: [
                SizedBox(
                  child: Image.asset(
                    "assets/images/capsicum.png",
                    height: screenWidth / 6.399,
                    width: screenWidth / 4.01,
                  ),
                  height: screenWidth / 6.399,
                  width: screenWidth / 4.01,
                ),
                SizedBox(width: screenWidth / 31.84),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    "Delivered On 20 Oct",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: screenWidth / 25.875),
                  ),
                  Text(
                    "Bell Pepper Red",
                    style: TextStyle(
                        fontSize: screenWidth / 25.875,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: screenWidth / 41.4),
                  Row(
                    children: List.generate(
                        5,
                        (index) => Icon(
                              Icons.star,
                              color: secondaryColor,

                            )),
                  )
                ]),
              ],
            ),
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth / 16.38, vertical: screenWidth / 17.25),
          ),
          SizedBox(width: screenWidth, height: screenWidth / 10.89),
          Expanded(
              child: ListView(
                  children: List.generate(
                      _faqsData.length,
                      (index) => IndividualHelpQuestion(
                          screenWidth: screenWidth,
                          title: "${_faqsData[index]["title"]}",
                          subtitle: "${_faqsData[index]["subtitle"]}",
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => FAQDetail()));
                          }))))
        ],
      ),
    );
  }
}

class IndividualHelpQuestion extends StatelessWidget {
  const IndividualHelpQuestion({
    Key? key,
    required this.screenWidth,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  }) : super(key: key);

  final double screenWidth;
  final String title, subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onPressed,
          trailing: Icon(Icons.keyboard_arrow_right),
          title: Text(
            "$title",
            style: TextStyle(
                fontWeight: FontWeight.w500, fontSize: screenWidth / 25.875),
          ),
          subtitle: Text(
            "$subtitle",
            style: TextStyle(
                color: Color(0xFF979797),
                fontWeight: FontWeight.w500,
                fontSize: screenWidth / 25.875),
          ),
        ),
        Container(
            margin: EdgeInsets.only(left: screenWidth / 32.62),
            width: screenWidth,
            height: 1,
            color: Color(0xFFE2E2E2)),
        SizedBox(
          height: screenWidth / 41.4,
        )
      ],
    );
  }
}
