import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickblox_polls_feature/bloc/chat/chat_screen_bloc.dart';
import 'package:quickblox_polls_feature/bloc/chat/chat_screen_events.dart';
import 'package:quickblox_polls_feature/models/poll_action.dart';
import 'package:quickblox_polls_feature/models/poll_message.dart';
import 'package:quickblox_polls_feature/presentation/screens/chat/avatar_noname.dart';
import 'package:quickblox_polls_feature/presentation/screens/chat/polls.dart';
import 'package:quickblox_sdk/chat/constants.dart';

class ChatPollItem extends StatelessWidget {
  final PollMessage message;

  final int? dialogType;

  const ChatPollItem({required this.message, this.dialogType, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<int?> voters =
        message.votes.keys.map((userId) => int.parse(userId)).toList();
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
                    child: Polls(
                      onVote: (pollOption, optionIndex) {
                        if (!hasVoted) {
                          Provider.of<ChatScreenBloc>(context, listen: false)
                              .events
                              ?.add(
                                VoteToPollEvent(
                                  PollActionVote(
                                    pollID: message.pollID,
                                    votes: message.votes,
                                    currentUserID:
                                        message.currentUserId.toString(),
                                    choosenOptionID: pollOption.optionId!,
                                  ),
                                ),
                              );
                        }
                      },
                      pollStyle: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 15,
                        color:
                            message.isIncoming ? Colors.black87 : Colors.white,
                      ),
                      backgroundColor:
                          message.isIncoming ? Colors.white : Colors.blue,
                      outlineColor: Colors.transparent,
                      hasVoted: hasVoted,
                      children: message.options.entries
                          .map((option) => PollOption(
                              optionId: option.key, //OptionID
                              option: option.value, //Option Value (Text)
                              value: message.votes.values
                                  .where((choosenOptionID) =>
                                      choosenOptionID == option.key)
                                  .length
                                  .toDouble()))
                          .toList(),
                      pollTitle: Text(
                        message.pollTitle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
