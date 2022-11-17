import 'dart:convert';

import 'package:uuid/uuid.dart';

class PollActionCreate {
  const PollActionCreate(
      {required this.pollId,
      required this.pollTitle,
      required this.pollOptions});
  final String pollId;
  final String pollTitle;
  final Map<String, String> pollOptions;

  factory PollActionCreate.fromData(String title, List<String> options) {
    const uuid = Uuid();
    return PollActionCreate(
        pollId: uuid.v4(),
        pollTitle: title,
        pollOptions: {for (var element in options) uuid.v4(): element});
  }
  Map<String, String> toJson() {
    return {
      "action": "pollActionCreate",
      "pollId": pollId,
      "pollTitle": pollTitle,
      "pollOptions": jsonEncode(pollOptions)
    };
  }
}

class PollActionVote {
  const PollActionVote({required this.pollId, required this.voteOptionId});
  final String pollId;

  final String voteOptionId;
  Map<String, String> toJson() {
    return {
      "action": "pollActionVote",
      "pollId": pollId,
      "chosenOption": voteOptionId
    };
  }
}
