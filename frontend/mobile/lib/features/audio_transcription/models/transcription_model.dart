class TranscriptionSegmentModel {
  final double startTime;
  final double endTime;
  final String text;
  final String speaker;

  const TranscriptionSegmentModel({
    required this.startTime,
    required this.endTime,
    required this.text,
    this.speaker = 'സ്പീക്കർ',
  });

  factory TranscriptionSegmentModel.fromJson(Map<String, dynamic> json) {
    return TranscriptionSegmentModel(
      startTime: (json['start_time'] as num?)?.toDouble() ?? 0.0,
      endTime: (json['end_time'] as num?)?.toDouble() ?? 0.0,
      text: json['text'] as String? ?? '',
      speaker: json['speaker'] as String? ?? 'സ്പീക്കർ',
    );
  }
}

class TranscriptionModel {
  final String id;
  final String status;
  final String language;
  final String fullText;
  final String? summary;
  final double durationSeconds;
  final List<TranscriptionSegmentModel> segments;
  final DateTime createdAt;

  const TranscriptionModel({
    required this.id,
    this.status = 'COMPLETED',
    this.language = 'ml',
    required this.fullText,
    this.summary,
    this.durationSeconds = 0.0,
    this.segments = const [],
    required this.createdAt,
  });

  factory TranscriptionModel.fromJson(Map<String, dynamic> json) {
    final segList = json['segments'] as List<dynamic>? ?? [];
    return TranscriptionModel(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'COMPLETED',
      language: json['language'] as String? ?? 'ml',
      fullText: json['full_text'] as String? ?? '',
      summary: json['summary'] as String?,
      durationSeconds: (json['duration_seconds'] as num?)?.toDouble() ?? 0.0,
      segments: segList
          .map((s) =>
              TranscriptionSegmentModel.fromJson(s as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
