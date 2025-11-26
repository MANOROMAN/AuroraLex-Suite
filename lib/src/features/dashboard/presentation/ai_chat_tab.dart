import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../screens/ai_legal_chat_screen.dart';

class AiChatTab extends HookConsumerWidget {
  const AiChatTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AILegalChatScreen();
  }
}