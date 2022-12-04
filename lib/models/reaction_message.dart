import 'dart:convert';

import 'package:quickblox_polls_feature/models/message_wrapper.dart';
import 'package:quickblox_sdk/models/qb_custom_object.dart';
import 'package:quickblox_sdk/models/qb_message.dart';

class ReactionMessage extends QBMessageWrapper {
  ReactionMessage(
    super.senderName,
    super.message,
    super.currentUserId, {
    required this.messageReactId,
    required this.reacts,
  });

  final String messageReactId;
  final Map<String, String> reacts;

  factory ReactionMessage.fromCustomObject(String senderName, QBMessage message,
      int currentUserId, QBCustomObject object) {
    return ReactionMessage(
      senderName,
      message,
      currentUserId,
      messageReactId: message.properties!['messageReactId']!,
      reacts: Map<String, String>.from(
        jsonDecode(object.fields!['reacts'] as String),
      ),
    );
  }
  ReactionMessage copyWith({Map<String, String>? reacts}) {
    return ReactionMessage(
      senderName!,
      qbMessage,
      currentUserId,
      messageReactId: messageReactId,
      reacts: reacts ?? this.reacts,
    );
  }
}

const REACTION_ID_MAP = {
  "#001": "assets/images/love.png",
  "#002": "assets/images/laugh.png",
  "#003": "assets/images/sad.png",
  "#004": "assets/images/angry.png",
  "#005": "assets/images/wow.png",
};
