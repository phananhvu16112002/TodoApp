import 'package:flutter/material.dart';

class MyInputFeild extends StatelessWidget {
  final String title;
  final String hint;
  final TextEditingController? controller;
  final Widget? widget;
  final bool? edit;
  const MyInputFeild(
      {super.key,
      required this.title,
      required this.hint,
      this.controller,
      this.edit,
      this.widget});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          // Text(
          //   title,
          //   style: TextStyle(
          //       color: Colors.white,
          //       fontWeight: FontWeight.w600,
          //       fontSize: 16.5,
          //       letterSpacing: 2),
          // ),
          Row(
            children: [
              Container(
                height: 55,
                width: title == 'Remind' ? 200 : 150,
                decoration: BoxDecoration(
                    color: Color(0xff2a2e3d),
                    borderRadius: BorderRadius.circular(15)),
                child: TextFormField(
                  readOnly: widget == null ? false : true,
                  controller: controller,
                  // enabled: edit,
                  style: const TextStyle(color: Colors.white, fontSize: 17),
                  maxLines: null,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: hint,
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 17),
                      contentPadding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                      )),
                ),
              ),
              widget == null ? Container() : Container(child: widget)
            ],
          )
        ],
      ),
    );
  }
}
