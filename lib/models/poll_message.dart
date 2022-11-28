import 'dart:convert';

import 'package:quickblox_polls_feature/models/message_wrapper.dart';
import 'package:quickblox_sdk/models/qb_custom_object.dart';
import 'package:quickblox_sdk/models/qb_message.dart';

class PollMessage extends QBMessageWrapper {
  PollMessage(super.senderName, super.message, super.currentUserId,
      {required this.pollID,
      required this.pollTitle,
      required this.options,
      required this.votes});

  final String pollID;
  final String pollTitle;
  final Map<String, String> options;
  final Map<String, String> votes;

  factory PollMessage.fromCustomObject(String senderName, QBMessage message,
      int currentUserId, QBCustomObject object) {
    return PollMessage(senderName, message, currentUserId,
        pollID: message.properties!['pollID']!,
        pollTitle: object.fields!['title'] as String,
        options: Map<String, String>.from(
            jsonDecode(object.fields!['options'] as String)),
        votes: Map<String, String>.from(
            jsonDecode(object.fields!['votes'] as String)));
  }
  PollMessage copyWith({Map<String, String>? votes}) {
    return PollMessage(senderName!, qbMessage, currentUserId,
        pollID: pollID,
        pollTitle: pollTitle,
        options: options,
        votes: votes ?? this.votes);
  }
}
