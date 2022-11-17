import 'dart:convert';

import 'package:quickblox_polls_feature/models/message_wrapper.dart';

class PollMessage extends QBMessageWrapper {
  PollMessage(super.senderName, super.message, super.currentUserId,
      {this.votes = const {}})
      : pollId = message.properties!['pollId']!,
        pollTitle = message.properties!['pollTitle']!,
        pollOptions = jsonDecode(message.properties!['pollOptions']!);
  final String pollId;
  final String pollTitle;
  final Map<String, String> pollOptions;

  ///<voterID, optionId>
  final Map<String, String> votes;

  factory PollMessage.fromQBMessageWrapper(QBMessageWrapper message,
      {Map<String, String> votes = const {}}) {
    return PollMessage(
        message.senderName!, message.qbMessage, message.currentUserId,
        votes: votes);
  }
}
