class VoiceMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? intent;
  final String? action;
  final String? targetRoute;
  final String? audioBase64;

  const VoiceMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.intent,
    this.action,
    this.targetRoute,
    this.audioBase64,
  });

  factory VoiceMessage.fromJson(Map<String, dynamic> json) {
    return VoiceMessage(
      id: json['id'] as String? ?? DateTime.now().toIso8601String(),
      text: json['assistant_reply'] as String? ?? json['text'] as String? ?? '',
      isUser: json['is_user'] as bool? ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      intent: json['intent'] as String?,
      action: json['action'] as String?,
      targetRoute: json['target_route'] as String?,
      audioBase64: json['audio_base64'] as String?,
    );
  }
}
