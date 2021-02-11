import 'package:flutter/material.dart';
import 'Inbox/InboxPage.dart';
import 'NewMessage/NewMessagePage.dart';
import 'Conversation/ConversationPage.dart';

void main() {
  runApp(CCSGACommentsApp());
}

class CCSGACommentsApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CCSGA Comments',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: ConversationPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
