import 'dart:convert';

class MessageReactProperties {
  const MessageReactProperties({
    required this.reacts,
  });
  final Map<String, String> reacts;

  Map<String, String> toJson() {
    return {
      "reacts": jsonEncode({}),
    };
  }

  factory MessageReactProperties.fromData() {
    return const MessageReactProperties(
      reacts: {},
    );
  }
}

class MessageActionReact {
  const MessageActionReact({
    required this.messageReactId,
    required this.reacts,
    required this.currentUserId,
    required this.chosenReactionId,
  });
  final String messageReactId;
  final Map<String, String> reacts;
  final String chosenReactionId;
  final String currentUserId;

  Map<String, String> get updatedReacts {
    reacts[currentUserId] = chosenReactionId;
    return {"reacts": jsonEncode(reacts)};
  }
}
