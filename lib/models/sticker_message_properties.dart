class StickerMessageProperties {
  final String stickerImgUrl;

  StickerMessageProperties({
    required this.stickerImgUrl,
  });

  Map<String, String> toJson() {
    return {
      "stickerImgUrl": stickerImgUrl,
      "action": "messageActionSticker",
    };
  }

  factory StickerMessageProperties.fromData(String stickerImage) {
    return StickerMessageProperties(
      stickerImgUrl: stickerImage,
    );
  }
}
