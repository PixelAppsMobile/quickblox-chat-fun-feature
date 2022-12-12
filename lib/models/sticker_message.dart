import 'package:quickblox_polls_feature/models/message_wrapper.dart';
import 'package:quickblox_sdk/models/qb_message.dart';

class StickerMessage extends QBMessageWrapper {
  StickerMessage(
    super.senderName,
    super.message,
    super.currentUserId, {
    required this.stickerImgUrl,
  });

  final String stickerImgUrl;

  factory StickerMessage.fromMessage(
      String senderName, QBMessage message, int currentUserId) {
    return StickerMessage(
      senderName,
      message,
      currentUserId,
      stickerImgUrl: message.properties!['stickerImgUrl']!,
    );
  }
  StickerMessage copyWith({String? stickerImgUrl}) {
    return StickerMessage(
      senderName!,
      qbMessage,
      currentUserId,
      stickerImgUrl: stickerImgUrl ?? this.stickerImgUrl,
    );
  }
}
