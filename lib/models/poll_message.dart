import 'dart:convert';

import 'package:quickblox_polls_feature/models/message_wrapper.dart';
import 'package:quickblox_sdk/models/qb_custom_object.dart';
import 'package:quickblox_sdk/models/qb_message.dart';

class PollMessageCreate extends QBMessageWrapper {
  PollMessageCreate(super.senderName, super.message, super.currentUserId,
      {required this.pollID,
      required this.pollTitle,
      required this.options,
      required this.votes})
      : assert(message.properties?['action'] == 'pollActionCreate',
            "The object is not a [PollMessageCreate]");

  final String pollID;
  final String pollTitle;
  final Map<String, String> options;
  final Map<String, String> votes;

  factory PollMessageCreate.fromCustomObject(String senderName,
      QBMessage message, int currentUserId, QBCustomObject object) {
    return PollMessageCreate(senderName, message, currentUserId,
        pollID: message.properties!['pollID']!,
        pollTitle: object.fields!['title'] as String,
        options: Map<String, String>.from(
            jsonDecode(object.fields!['options'] as String)),
        votes: Map<String, String>.from(
            jsonDecode(object.fields!['votes'] as String)));
  }
}

class PollMessageVote extends QBMessageWrapper {
  PollMessageVote(super.senderName, super.message, super.currentUserId)
      : assert(message.properties?['action'] == 'pollActionVote',
            "The object is not a [PollMessageVote]");

  String get pollID => qbMessage.properties!['pollId']!;
  String get choosenOption => qbMessage.properties!['chosenOption']!;
  int? get senderID => qbMessage.senderId;
}
