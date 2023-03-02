import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';

class MessageItem extends StatelessWidget {
  const MessageItem({super.key, required this.sentByMe, required this.message});

  final bool sentByMe;
  final String message;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        margin: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
            color: sentByMe ? Color(0xff8F98FF) : Color(0xffE4E4E4),
            borderRadius: BorderRadius.circular(10.0)),
        child: Text(message,
            style: TextStyle(
              color: sentByMe ? Color(0xffffffff) : Color(0xff000000),
              fontWeight: FontWeight.w400,
              fontSize: 18,
            )),
      ),
    );
  }
}
