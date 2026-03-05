import 'package:flutter/material.dart';

class MarkdownToolbar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onChanged;

  const MarkdownToolbar({
    Key? key,
    required this.controller,
    this.onChanged,
  }) : super(key: key);

  void _wrapSelection(String before, String after) {
    final text = controller.text;
    final selection = controller.selection;

    if (!selection.isValid || selection.isCollapsed) {
      final insert = '${before}text$after';
      final newText =
          text.replaceRange(selection.baseOffset, selection.baseOffset, insert);
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: selection.baseOffset + before.length + 1,
        ),
      );
    } else {
      final selected = text.substring(selection.start, selection.end);
      final replacement = '$before$selected$after';
      final newText =
          text.replaceRange(selection.start, selection.end, replacement);
      controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection(
          baseOffset: selection.start + before.length,
          extentOffset: selection.start + before.length + selected.length,
        ),
      );
    }
    onChanged?.call();
  }

  void _insertAtLineStart(String prefix) {
    final text = controller.text;
    final selection = controller.selection;
    final offset = selection.baseOffset.clamp(0, text.length);

    int lineStart = text.lastIndexOf('\n', offset > 0 ? offset - 1 : 0);
    lineStart = lineStart == -1 ? 0 : lineStart + 1;

    final newText = text.replaceRange(lineStart, lineStart, prefix);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: offset + prefix.length),
    );
    onChanged?.call();
  }

  void _insertText(String insert) {
    final text = controller.text;
    final selection = controller.selection;
    final offset = selection.baseOffset.clamp(0, text.length);

    final newText = text.replaceRange(offset, offset, insert);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: offset + insert.length),
    );
    onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        border: Border(
          top: BorderSide(color: Color(0xFF2C2C2E)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            _Btn(icon: Icons.format_bold, tooltip: 'Bold', onTap: () => _wrapSelection('**', '**')),
            _Btn(icon: Icons.format_italic, tooltip: 'Italic', onTap: () => _wrapSelection('_', '_')),
            _Btn(icon: Icons.format_strikethrough, tooltip: 'Strikethrough', onTap: () => _wrapSelection('~~', '~~')),
            _divider(),
            _Btn(icon: Icons.title, tooltip: 'H1', onTap: () => _insertAtLineStart('# ')),
            _Btn(icon: Icons.text_fields, tooltip: 'H2', onTap: () => _insertAtLineStart('## ')),
            _Btn(icon: Icons.text_format, tooltip: 'H3', onTap: () => _insertAtLineStart('### ')),
            _divider(),
            _Btn(icon: Icons.format_list_bulleted, tooltip: 'Bullet List', onTap: () => _insertAtLineStart('- ')),
            _Btn(icon: Icons.format_list_numbered, tooltip: 'Numbered List', onTap: () => _insertAtLineStart('1. ')),
            _Btn(icon: Icons.checklist, tooltip: 'Task List', onTap: () => _insertAtLineStart('- [ ] ')),
            _divider(),
            _Btn(icon: Icons.format_quote, tooltip: 'Quote', onTap: () => _insertAtLineStart('> ')),
            _Btn(icon: Icons.code, tooltip: 'Code', onTap: () => _wrapSelection('`', '`')),
            _Btn(icon: Icons.integration_instructions, tooltip: 'Code Block', onTap: () => _insertText('\n```\n\n```\n')),
            _divider(),
            _Btn(icon: Icons.link, tooltip: 'Link', onTap: () => _insertText('[link text](url)')),
            _Btn(icon: Icons.horizontal_rule, tooltip: 'Divider', onTap: () => _insertText('\n---\n')),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        height: 20,
        child: VerticalDivider(
          width: 1,
          color: Colors.grey[800],
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _Btn({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Icon(icon, size: 19, color: Colors.grey[400]),
        ),
      ),
    );
  }
}
