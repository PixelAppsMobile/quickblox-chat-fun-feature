import 'dart:convert';

import 'package:quickblox_polls_feature/models/poll_message.dart';
import 'package:uuid/uuid.dart';

class PollActionCreate {
  PollActionCreate({
    required this.pollId,
    required this.pollTitle,
    required this.pollOptions,
  });
  final String pollId;
  final String pollTitle;
  final Map<String, String> pollOptions;

  factory PollActionCreate.fromData(
    String title,
    List<String> options,
  ) {
    const uuid = Uuid();
    return PollActionCreate(
      pollId: uuid.v4(),
      pollTitle: title,
      pollOptions: {for (var element in options) uuid.v4(): element},
    );
  }
  Map<String, String> toJson() {
    return {
      "title": pollTitle,
      "options": jsonEncode(pollOptions),
      "votes": jsonEncode({})
    };
  }
}

class PollActionVote {
  const PollActionVote({required this.poll, required this.choosenOptionID});
  final PollMessageCreate poll;
  final String choosenOptionID;

  Map<String, String> get updatedFields {
    final votes = poll.votes;
    votes[poll.currentUserId.toString()] = choosenOptionID;
    return {
      "title": poll.pollTitle,
      "options": jsonEncode(poll.options),
      "votes": jsonEncode(votes)
    };
  }
}
