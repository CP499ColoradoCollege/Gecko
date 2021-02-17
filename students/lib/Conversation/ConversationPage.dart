import 'package:ccsga_comments/BasePage/BasePage.dart';
import 'package:ccsga_comments/Conversation/MessageThread.dart';
import 'package:ccsga_comments/Models/ChewedResponseModel.dart';
import 'package:ccsga_comments/DatabaseHandler.dart';
import 'package:ccsga_comments/Models/Conversation.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class ConversationPage extends BasePage {
  final int conversationId;

  ConversationPage({Key key, @required this.conversationId}) : super(key: key);

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends BaseState<ConversationPage>
    with BasicPage {
  final messageFieldController = TextEditingController();

  @override
  void initState() {
    _getConversationData();
    super.initState();
  }

  @override
  Widget body() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
      child: Column(
        children: [
          MessageThread(),
          TextFormField(
            controller: messageFieldController,
            minLines: 2,
            maxLines: 6,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              labelText: 'Write a message',
              labelStyle: TextStyle(color: Colors.black),
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black),
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  _sendMessage();
                },
                icon: Icon(Icons.send_rounded),
              ),
            ),
            validator: (value) {
              if (value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          )
        ],
      ),
    );
  }

  @override
  String screenName() {
    return "Conversation Thread";
  }

  void _getConversationData() async {
    Tuple2<ChewedResponse, Conversation> responseTuple =
        await DatabaseHandler.instance.getConversation(widget.conversationId);
    // transaction successful, there was a conv obj sent in response
    if (responseTuple.item2 != null) {
      // use setState to update the data in the UI with conv
      Conversation conv = responseTuple.item2;
      print(conv);
    } else {
      setState(() {
        // _errorMessage = responseTuple.item1.message;
      });
    }
  }

  void _sendMessage() async {
    if (this.messageFieldController.text != "") {
      ChewedResponse chewedResponse = await DatabaseHandler.instance
          .sendMessageInConversation(1, messageFieldController.text);
      if (chewedResponse.isSuccessful) {
        messageFieldController.clear();
        setState(() {
          // _successMessage = chewedResponse.message;
        });
      } else {
        setState(() {
          // _errorMessage = chewedResponse.message;
        });
      }
    }
  }
}
