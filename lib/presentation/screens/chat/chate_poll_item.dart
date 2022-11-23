import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickblox_polls_feature/bloc/chat/chat_screen_bloc.dart';
import 'package:quickblox_polls_feature/bloc/chat/chat_screen_events.dart';
import 'package:quickblox_polls_feature/models/create_poll.dart';
import 'package:quickblox_polls_feature/models/poll_message.dart';
import 'package:quickblox_polls_feature/presentation/screens/chat/avatar_noname.dart';
import 'package:quickblox_polls_feature/presentation/screens/chat/polls.dart';
import 'package:quickblox_sdk/chat/constants.dart';

class ChatPollItem extends StatelessWidget {
  final PollMessageCreate message;
  final List<PollMessageVote> votes;
  final int? dialogType;

  const ChatPollItem(
      {required this.message, required this.votes, this.dialogType, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<int?> voters = votes.map((e) => e.senderID).toList();
    bool hasVoted = voters.contains(message.currentUserId);

    return Container(
      padding: const EdgeInsets.only(left: 10, right: 12, bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
              child: message.isIncoming && dialogType != QBChatDialogTypes.CHAT
                  ? AvatarFromName(name: message.senderName)
                  : null),
          Padding(padding: EdgeInsets.only(left: dialogType == 3 ? 0 : 16)),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Column(
              crossAxisAlignment: message.isIncoming
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: <Widget>[
                IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Polls(
                        onVote: (pollOption, optionIndex) {
                          if (!hasVoted) {
                            Provider.of<ChatScreenBloc>(context, listen: false)
                                .events
                                ?.add(
                                  VoteToPollEvent(
                                    PollActionVote(
                                      pollId: message.pollID,
                                      voteOptionId: pollOption.optionId!,
                                    ),
                                  ),
                                );
                          }
                        },
                        pollStyle: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          fontSize: 15,
                          color: message.isIncoming
                              ? Colors.black87
                              : Colors.white,
                        ),
                        backgroundColor:
                            message.isIncoming ? Colors.white : Colors.blue,
                        outlineColor: Colors.transparent,
                        hasVoted: hasVoted,
                        children: message.options.entries
                            .map((e) => PollOption(
                                optionId: e.key,
                                option: e.value,
                                value: votes
                                    .map((e) => e.choosenOption)
                                    .where((option) => option == e.key)
                                    .length
                                    .toDouble()))
                            .toList(),
                        question: Text(
                          message.pollTitle,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }
}
