import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const actions = ['Report an Incident', 'Find Past Questions', 'University Rules', 'Scholarships', 'Other Help'];
    return Scaffold(
      appBar: AppBar(title: const Text('BUK Bot')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.circle, size: 8, color: Color(AppColors.primaryDeeper)),
                SizedBox(width: 6),
                Text('Online', style: TextStyle(color: Color(AppColors.primaryDeeper), fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.all(12),
                constraints: const BoxConstraints(maxWidth: 280),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(14)),
                child: const Text('Hi Abubakar! I\'m BUK Bot. How can I help you today?'),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: actions
                  .map((e) => ActionChip(
                        label: Text(e),
                        avatar: const Icon(Icons.bolt_rounded, size: 16),
                        onPressed: () {},
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.all(12),
                constraints: const BoxConstraints(maxWidth: 280),
                decoration: BoxDecoration(color: const Color(0x120085D0), borderRadius: BorderRadius.circular(14)),
                child: const Text('Show me past questions for CSC 202.'),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                const Expanded(child: TextField(decoration: InputDecoration(hintText: 'Type your message...'))),
                const SizedBox(width: 8),
                Semantics(
                  button: true,
                  label: 'Send message',
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(AppColors.primaryDeeper),
                    child: IconButton(onPressed: () {}, icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
