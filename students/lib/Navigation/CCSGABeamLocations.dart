import 'package:beamer/beamer.dart';
import 'package:ccsga_comments/Admin/AdminPage.dart';
import 'package:ccsga_comments/Home/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:ccsga_comments/ConversationList/ConversationListPage.dart';
import 'package:ccsga_comments/NewMessage/NewMessagePage.dart';
import 'package:ccsga_comments/Conversation/ConversationPage.dart';

const List<String> _homePath = [''];
const List<String> _conversationListPath = ['conversation_list'];
const List<String> _conversationPath = ['conversation/:conversationId'];
const List<String> _newMessagePath = ['new_message'];
const List<String> _adminPath = ['admin_controls'];
const List<String> _loginPath = ['login'];

class HomeLocation extends BeamLocation {
  HomeLocation() {
    pathSegments = _homePath;
  }
  @override
  List<String> get pathBlueprints => _homePath;

  @override
  List<BeamPage> get pages => [
        BeamPage(
          key: ValueKey('home'),
          child: HomePage(),
        ),
      ];
}

class AdminLocation extends BeamLocation {
  AdminLocation() {
    pathSegments = _adminPath;
  }
  @override
  List<String> get pathBlueprints => _adminPath;

  @override
  List<BeamPage> get pages => [
        BeamPage(
          key: ValueKey('admin'),
          child: AdminPage(),
        ),
      ];
}

class ConversationListLocation extends BeamLocation {
  ConversationListLocation() {
    pathSegments = _conversationListPath;
  }
  @override
  List<String> get pathBlueprints => _conversationListPath;

  @override
  List<BeamPage> get pages => [
        BeamPage(
          key: ValueKey('conversation_list'),
          child: ConversationListPage(),
        ),
      ];
}

class ConversationLocation extends BeamLocation {
  ConversationLocation(
      {Map<String, String> pathParameters, Map<String, dynamic> data})
      : super(
            pathBlueprint: _conversationPath.last,
            pathParameters: pathParameters,
            data: data);

  @override
  List<String> get pathBlueprints => _conversationPath;

  @override
  List<BeamPage> get pages => [
        ...ConversationListLocation().pages,
        if (pathParameters.containsKey('conversationId'))
          BeamPage(
            key: ValueKey(
                'conversation-${pathParameters['conversationId'] ?? ''}'),
            child: ConversationPage(
                conversationId:
                    int.parse(pathParameters['conversationId'] ?? 0)),
          ),
        if (data.containsKey('convId'))
          BeamPage(
              key: ValueKey('conversation-${data['convId'] ?? ''}'),
              child: ConversationPage(conversationId: data['convId'] ?? 0)),
      ];
}

class NewMessageLocation extends BeamLocation {
  NewMessageLocation() {
    pathSegments = _newMessagePath;
  }

  @override
  List<String> get pathBlueprints => _newMessagePath;

  @override
  List<BeamPage> get pages => [
        BeamPage(
          key: ValueKey('new_message'),
          child: NewMessagePage(),
        ),
      ];
}
