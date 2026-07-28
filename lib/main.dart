import 'package:flutter/material.dart';

import 'hanzo.dart';
import 'settings.dart';
import 'theme.dart';

void main() => runApp(const ChatApp());

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Hanzo Chat',
        debugShowCheckedModeBanner: false,
        theme: hanzoTheme(),
        home: const ChatPage(),
      );
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const _greeting =
      Msg('assistant', 'Ask me anything. Set a Hanzo API key in Settings to talk to a real model.');

  final _msgs = <Msg>[_greeting];
  final _input = TextEditingController();
  final _scroll = ScrollController();
  bool _busy = false;
  String? _err;

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _busy) return;

    // Push the user turn plus an empty assistant turn, then stream into it.
    final history = [..._msgs.where((m) => m != _greeting), Msg('user', text)];
    setState(() {
      _input.clear();
      _err = null;
      _busy = true;
      _msgs
        ..clear()
        ..addAll([...history, const Msg('assistant', '')]);
    });

    try {
      await for (final chunk in Hanzo.instance.complete(history)) {
        setState(() => _msgs[_msgs.length - 1] = Msg('assistant', _msgs.last.content + chunk));
        _toBottom();
      }
    } catch (e) {
      setState(() {
        _err = '$e';
        _msgs
          ..clear()
          ..addAll(history);
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toBottom() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
      });

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Hanzo Chat'),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const SettingsPage())),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.separated(
                controller: _scroll,
                padding: const EdgeInsets.all(16),
                itemCount: _msgs.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) => Bubble(msg: _msgs[i]),
              ),
            ),
            if (_err != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(_err!, style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 13)),
              ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _input,
                        minLines: 1,
                        maxLines: 5,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: 'Message ${Hanzo.instance.model}',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: _busy ? null : _send,
                      style: FilledButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(14),
                      ),
                      child: _busy
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.arrow_upward, size: 18),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

class Bubble extends StatelessWidget {
  const Bubble({super.key, required this.msg});
  final Msg msg;

  @override
  Widget build(BuildContext context) {
    final mine = msg.role == 'user';
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.86),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: mine ? seed : const Color(0xFF141417),
          border: mine ? null : Border.all(color: const Color(0xFF232329)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(mine ? 18 : 4),
            bottomRight: Radius.circular(mine ? 4 : 18),
          ),
        ),
        child: Text(
          msg.content.isEmpty ? '…' : msg.content,
          style: TextStyle(color: mine ? Colors.white : Colors.white.withValues(alpha: 0.92), height: 1.4),
        ),
      ),
    );
  }
}
