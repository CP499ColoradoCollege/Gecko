import 'package:beamer/beamer.dart';
import 'package:ccsga_comments/Navigation/CCSGABeamLocations.dart';
import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';
import 'package:intl/intl.dart';

class ConversationListCard extends StatelessWidget {
  final int convId;
  final String joinedLabels;
  final String mostRecentMessageBody;
  final String mostRecentMessageDateTime;

  ConversationListCard(
      {this.convId,
      this.joinedLabels,
      this.mostRecentMessageBody,
      this.mostRecentMessageDateTime});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          print("Conversation ID:" + convId.toString());
          context.beamTo(ConversationLocation(
              pathParameters: {"conversationId": convId.toString()}));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.message_outlined),
              title: Text("CCSGA " + joinedLabels),
              subtitle: Text(mostRecentMessageBody),
              isThreeLine: true,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Text(
                    DateFormat("MMM d -")
                        .add_jm()
                        .format(DateTime.parse(mostRecentMessageDateTime))
                        .toString(),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
