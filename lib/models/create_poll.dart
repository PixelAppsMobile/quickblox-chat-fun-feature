import 'dart:convert';

import 'package:uuid/uuid.dart';

class PollActionCreate {
  PollActionCreate({
    required this.pollId,
    required this.pollTitle,
    required this.pollOptions,
    // required this.pollVoters,
  });
  final String pollId;
  final String pollTitle;
  final Map<String, String> pollOptions;
  // final Map<String, List<int>> pollVoters;

  factory PollActionCreate.fromData(
    String title,
    List<String> options,
    // final Map<String, List<int>> pollVoters,
  ) {
    const uuid = Uuid();
    return PollActionCreate(
      pollId: uuid.v4(),
      pollTitle: title,
      pollOptions: {for (var element in options) uuid.v4(): element},
      // pollVoters: pollVoters,
    );
  }
  Map<String, String> toJson() {
    return {
      "action": "pollActionCreate",
      "pollId": pollId,
      "pollTitle": pollTitle,
      "pollOptions": jsonEncode(pollOptions),
      // "pollVoters": jsonEncode(pollVoters),
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
