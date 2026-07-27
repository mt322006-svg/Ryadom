import 'package:shared_preferences/shared_preferences.dart';

import '../../requests/domain/help_request.dart';

enum ChatPalette {
  calm('Спокойная'),
  night('Ночная'),
  warm('Теплая'),
  cyberpunk('Киберпанк');

  const ChatPalette(this.label);
  final String label;
}

class ChatParticipant {
  const ChatParticipant({
    required this.name,
    required this.subtitle,
    required this.isCurrentUser,
  });

  final String name;
  final String subtitle;
  final bool isCurrentUser;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.authorName,
    required this.text,
    required this.timeLabel,
    required this.isCurrentUser,
  });

  final String id;
  final String authorName;
  final String text;
  final String timeLabel;
  final bool isCurrentUser;
}

class HelpChatSession {
  const HelpChatSession({
    required this.request,
    required this.title,
    required this.statusLabel,
    required this.participant,
    required this.requestEventId,
    required this.requestAuthorPubkey,
    required this.participantPubkey,
    this.messages = const [],
  });

  final HelpRequest request;
  final String title;
  final String statusLabel;
  final ChatParticipant participant;
  final String requestEventId;
  final String requestAuthorPubkey;
  final String? participantPubkey;
  final List<ChatMessage> messages;
}

abstract final class ChatPaletteStore {
  static const _prefsKey = 'ryadom_chat_palette_v1';

  static Future<ChatPalette?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return ChatPalette.values.firstWhere(
      (item) => item.name == raw,
      orElse: () => ChatPalette.night,
    );
  }

  static Future<void> save(ChatPalette palette) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_prefsKey, palette.name);
  }
}
