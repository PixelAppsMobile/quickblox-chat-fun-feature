import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickblox_polls_feature/models/poll_message.dart';
import 'package:quickblox_sdk/chat/constants.dart';

import '../../../base_bloc.dart';
import '../../../bloc/chat/chat_screen_bloc.dart';
import '../../../bloc/chat/chat_screen_events.dart';
import '../../../models/message_wrapper.dart';
import '../../../utils/color_util.dart';

class ChatListItem extends StatefulWidget {
  final QBMessageWrapper _message;
  final int? _dialogType;

  const ChatListItem(Key key, this._message, this._dialogType)
      : super(key: key);

  @override
  ChatListItemState createState() => ChatListItemState(_message, _dialogType);
}

class ChatListItemState extends State<ChatListItem> {
  final QBMessageWrapper _message;
  final int? _dialogType;
  Bloc? _bloc;

  ChatListItemState(this._message, this._dialogType);

  @override
  Widget build(BuildContext context) {
    _bloc = Provider.of<ChatScreenBloc>(context, listen: false);

    if (_message.qbMessage.readIds != null &&
        !_message.qbMessage.readIds!.contains(_message.currentUserId)) {
      _message.qbMessage.readIds!.add(_message.currentUserId);
      _bloc?.events?.add(MarkMessageRead(_message.qbMessage));
    }
    var messageProperties = _message.qbMessage.properties;
    bool isNotification = (messageProperties != null &&
        messageProperties.containsKey("notification_type"));

    if (isNotification) {
      _message.qbMessage.body ??= "empty message";
      return Container(
        padding: const EdgeInsets.all(14),
        alignment: Alignment.center,
        constraints: const BoxConstraints(maxWidth: 250),
        child: Text(
          _message.qbMessage.body!,
          maxLines: null,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xff6c7a92),
          ),
          overflow: TextOverflow.clip,
        ),
      );
    }

    bool isPoll = _message is PollMessage;

    ///TODO: Handle Polls
    if (isPoll) {
      return Container(
        color: Colors.red,
        child: const Text('This is a POLL message'),
      );
    }

    return Container(
      padding: const EdgeInsets.only(left: 10, right: 12, bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Container(
              child:
                  _message.isIncoming && _dialogType != QBChatDialogTypes.CHAT
                      ? _generateAvatarFromName(_message.senderName)
                      : null),
          Padding(padding: EdgeInsets.only(left: _dialogType == 3 ? 0 : 16)),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(top: 15),
            child: Column(
              crossAxisAlignment: _message.isIncoming
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: <Widget>[
                IntrinsicWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _buildNameTimeHeader(),
                      ),
                      _buildMessageBody()
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

  List<Widget> _buildNameTimeHeader() {
    return <Widget>[
      const Padding(padding: EdgeInsets.only(left: 16)),
      _buildSenderName(),
      const Padding(padding: EdgeInsets.only(left: 7)),
      const Expanded(child: SizedBox.shrink()),
      _message.isIncoming ? const SizedBox.shrink() : _buildMessageStatus(),
      const Padding(padding: EdgeInsets.only(left: 3)),
      _buildDateSent(),
      const Padding(padding: EdgeInsets.only(left: 16))
    ];
  }

  Widget _buildMessageStatus() {
    var deliveredIds = _message.qbMessage.deliveredIds;
    var readIds = _message.qbMessage.readIds;
    if (_dialogType == QBChatDialogTypes.PUBLIC_CHAT) {
      return const SizedBox.shrink();
    }
    if (readIds != null && readIds.length > 1) {
      return SvgPicture.asset('assets/icons/read.svg');
    } else if (deliveredIds != null && deliveredIds.length > 1) {
      return SvgPicture.asset('assets/icons/delivered.svg');
    } else {
      return SvgPicture.asset('assets/icons/sent.svg');
    }
  }

  Widget _buildSenderName() {
    return Text(
      _message.senderName ?? "Noname",
      maxLines: 1,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildDateSent() {
    return Text(
      _buildTime(_message.qbMessage.dateSent!),
      maxLines: 1,
      style: const TextStyle(
        fontSize: 13,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildMessageBody() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 234),
      decoration: BoxDecoration(
          color: _message.isIncoming ? Colors.white : Colors.blue,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(22),
            topRight: const Radius.circular(22),
            bottomRight: _message.isIncoming
                ? const Radius.circular(22)
                : const Radius.circular(0),
            bottomLeft: _message.isIncoming
                ? const Radius.circular(0)
                : const Radius.circular(22),
          ),
          boxShadow: [
            BoxShadow(
              color: _message.isIncoming
                  ? Colors.blue.withOpacity(0.15)
                  : Colors.blue.withOpacity(0.35),
              spreadRadius: _message.isIncoming ? 0 : 3,
              blurRadius: _message.isIncoming ? 48 : 27,
              offset: _message.isIncoming
                  ? const Offset(0, 3)
                  : const Offset(5, 12),
            )
          ]),
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 13,
        bottom: 13,
      ),
      child: Text(
        _message.qbMessage.body ?? "[Attachment]",
        maxLines: null,
        style: TextStyle(
          fontSize: 15,
          color: _message.isIncoming ? Colors.black87 : Colors.white,
        ),
        overflow: TextOverflow.clip,
      ),
    );
  }

  Widget _generateAvatarFromName(String? name) {
    name ??= "Noname";
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Color(ColorUtil.getColor(name)),
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: Center(
        child: Text(
          name.substring(0, 1).toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _buildTime(int timeStamp) {
    String completedTime = "";
    DateFormat timeFormat = DateFormat("HH:mm");
    DateTime messageTime =
        DateTime.fromMicrosecondsSinceEpoch(timeStamp * 1000);
    completedTime = timeFormat.format(messageTime);

    return completedTime;
  }
}
