import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotifiedPage extends StatelessWidget {
  final String? label;
  const NotifiedPage({Key? key, required this.label}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Get.isDarkMode?Colors.grey[600]: Colors.white,
        leading: IconButton(
            onPressed: () => Get.back, icon: Icon(Icons.arrow_back_ios),color: Colors.black,),
            title: Text(this.label.toString().split("|")[0], style: TextStyle(color: Colors.black),),
      ),
      
    );
  }
}
