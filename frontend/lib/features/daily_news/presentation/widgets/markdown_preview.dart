import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownPreview extends StatelessWidget {
  final String data;

  const MarkdownPreview({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 44, color: Colors.grey[800]),
            const SizedBox(height: 14),
            Text(
              'Nothing to preview',
              style: TextStyle(color: Colors.grey[700], fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Start writing to see it here',
              style: TextStyle(color: Colors.grey[800], fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Markdown(
      data: data,
      selectable: true,
      padding: const EdgeInsets.only(bottom: 40),
      styleSheet: MarkdownStyleSheet(
        h1: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        h2: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        h3: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        p: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          height: 1.75,
        ),
        strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        em: const TextStyle(color: Color(0xFFD0D0D0), fontStyle: FontStyle.italic),
        a: const TextStyle(color: Color(0xFF6B9FFF)),
        del: TextStyle(color: Colors.grey[600]),
        listBullet: const TextStyle(color: Color(0xFF8E8E93), fontSize: 16),
        code: const TextStyle(
          color: Color(0xFFE8C07D),
          backgroundColor: Color(0xFF2C2C2E),
          fontFamily: 'monospace',
          fontSize: 14,
        ),
        codeblockDecoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2C2C2E)),
        ),
        codeblockPadding: const EdgeInsets.all(16),
        blockquoteDecoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: Color(0xFF6B9FFF), width: 3),
          ),
        ),
        blockquotePadding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
        horizontalRuleDecoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFF2C2C2E), width: 1),
          ),
        ),
      ),
    );
  }
}
