import 'package:quickblox_polls_feature/models/message_action_react.dart';
import 'package:quickblox_polls_feature/models/poll_action.dart';
import 'package:quickblox_polls_feature/models/sticker_message_properties.dart';
import 'package:quickblox_sdk/models/qb_message.dart';

/// Created by Injoit in 2021.
/// Copyright © 2021 Quickblox. All rights reserved.

abstract class ChatScreenEvents {}

class ConnectChatEvent extends ChatScreenEvents {}

class UpdateChatEvent extends ChatScreenEvents {}

class ReturnToDialogsEvent extends ChatScreenEvents {}

class StartTypingEvent extends ChatScreenEvents {}

class StopTypingEvent extends ChatScreenEvents {}

class UsersAddedEvent extends ChatScreenEvents {
  final List<int> addedUsersIds;

  UsersAddedEvent(this.addedUsersIds);
}

class SendMessageEvent extends ChatScreenEvents {
  final String? textMessage;

  SendMessageEvent(this.textMessage);
}

class ReactMessageEvent extends ChatScreenEvents {
  final MessageActionReact data;

  ReactMessageEvent(this.data);
}

class CreatePollMessageEvent extends ChatScreenEvents {
  final PollActionCreate data;

  CreatePollMessageEvent(this.data);
}

class VoteToPollEvent extends ChatScreenEvents {
  final PollActionVote data;
  VoteToPollEvent(this.data);
}

class SendStickerMessageEvent extends ChatScreenEvents {
  final StickerMessageProperties stickerMessageProperties;

  SendStickerMessageEvent(this.stickerMessageProperties);
}

class MarkMessageRead extends ChatScreenEvents {
  final QBMessage message;

  MarkMessageRead(this.message);
}

class LeaveChatEvent extends ChatScreenEvents {}

class LeaveChatScreenEvent extends ChatScreenEvents {}

class ReturnChatScreenEvent extends ChatScreenEvents {}

class DeleteChatEvent extends ChatScreenEvents {}

class LoadNextMessagesPageEvent extends ChatScreenEvents {}
