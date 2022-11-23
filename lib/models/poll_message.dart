import 'dart:convert';

import 'package:quickblox_polls_feature/models/message_wrapper.dart';

class PollMessageCreate extends QBMessageWrapper {
  PollMessageCreate(super.senderName, super.message, super.currentUserId)
      : assert(message.properties?['action'] == 'pollActionCreate',
            "The object is not a [PollMessageCreate]");

  String get pollID => qbMessage.properties!['pollId']!;
  String get pollTitle => qbMessage.properties!['pollTitle']!;
  Map<String, String> get options =>
      Map.from(jsonDecode(qbMessage.properties!['pollOptions']!));
}

class PollMessageVote extends QBMessageWrapper {
  PollMessageVote(super.senderName, super.message, super.currentUserId)
      : assert(message.properties?['action'] == 'pollActionVote',
            "The object is not a [PollMessageVote]");

  String get pollID => qbMessage.properties!['pollId']!;
  String get choosenOption => qbMessage.properties!['chosenOption']!;
  int? get senderID => qbMessage.senderId;
}
