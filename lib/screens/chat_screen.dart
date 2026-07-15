import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import '../models/chat_message.dart';
import '../state/buddy_state.dart';
import '../theme/buddy_theme.dart';
import '../widgets/atmosphere.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _picker = ImagePicker();
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();

  bool _recording = false;
  String? _playingPath;

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _ctrl.text;
    _ctrl.clear();
    await context.read<BuddyState>().sendText(text);
    _scrollToEnd();
  }

  Future<void> _pickPhoto() async {
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (x == null || !mounted) return;
    await context.read<BuddyState>().sendPhoto(File(x.path));
    _scrollToEnd();
  }

  Future<void> _toggleRecord() async {
    if (_recording) {
      final path = await _recorder.stop();
      setState(() => _recording = false);
      if (path != null && mounted) {
        await context.read<BuddyState>().sendVoiceNote(File(path));
        _scrollToEnd();
      }
      return;
    }

    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission needed for voice notes.')),
      );
      return;
    }

    final dir = await getTemporaryDirectory();
    final path = p.join(dir.path, '${const Uuid().v4()}.m4a');
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );
    setState(() => _recording = true);
  }

  Future<void> _play(String path) async {
    if (_playingPath == path) {
      await _player.stop();
      setState(() => _playingPath = null);
      return;
    }
    await _player.stop();
    await _player.play(DeviceFileSource(path));
    setState(() => _playingPath = path);
    _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playingPath = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<BuddyState>();
    final buddy = state.profile.buddyName;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? BuddyColors.sage : BuddyColors.moss;

    return Atmosphere(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(buddy),
              Text(
                'Companion · voice, text, photos',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: accent,
                    ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Ask Buddy to check in',
              onPressed: () => state.askCheckIn(),
              icon: const Icon(Icons.waving_hand_outlined),
            ),
          ],
        ),
        body: Column(
          children: [
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _Chip(
                    label: 'Encourage me',
                    onTap: () => state.askAppreciation(),
                  ),
                  _Chip(label: 'Deen nudge', onTap: () => state.askDawah()),
                  _Chip(
                    label: 'Discipline',
                    onTap: () => state.askDisciplineNudge(),
                  ),
                  _Chip(
                    label: 'How’s my day',
                    onTap: () {
                      _ctrl.text = 'Can you check in on my day?';
                      _send();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: state.messages.length + (state.busy ? 1 : 0),
                itemBuilder: (context, index) {
                  if (state.busy && index == state.messages.length) {
                    return const _TypingBubble();
                  }
                  final msg = state.messages[index];
                  return _Bubble(
                    message: msg,
                    playing: _playingPath == msg.audioPath,
                    onPlay: msg.audioPath == null
                        ? null
                        : () => _play(msg.audioPath!),
                  );
                },
              ),
            ),
            if (_recording)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'Recording… tap mic to send',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: BuddyColors.warm,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 12, 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _pickPhoto,
                      icon: const Icon(Icons.photo_outlined),
                      color: accent,
                    ),
                    IconButton(
                      onPressed: _toggleRecord,
                      icon: Icon(
                        _recording ? Icons.stop_circle_outlined : Icons.mic_none,
                      ),
                      color: _recording ? BuddyColors.softRed : accent,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _send(),
                        decoration: InputDecoration(
                          hintText: 'Dump it here. I can hold it.',
                          suffixIcon: IconButton(
                            onPressed: _send,
                            icon: const Icon(Icons.send_rounded),
                            color: BuddyColors.warm,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        onPressed: onTap,
        backgroundColor: Theme.of(context).cardTheme.color,
        side: BorderSide.none,
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.message,
    required this.playing,
    this.onPlay,
  });

  final ChatMessage message;
  final bool playing;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    final mine = message.sender == MessageSender.user;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final time = DateFormat.jm().format(message.createdAt);
    final bg = mine
        ? BuddyColors.bubbleUser
        : (dark ? BuddyColors.nightBuddyBubble : BuddyColors.bubbleBuddy);
    final fg = mine
        ? BuddyColors.sand
        : (dark ? BuddyColors.nightText : BuddyColors.ink);

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(mine ? 18 : 4),
            bottomRight: Radius.circular(mine ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.imagePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(message.imagePath!),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (message.audioPath != null) ...[
              InkWell(
                onTap: onPlay,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      color: fg,
                      size: 32,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      playing ? 'Playing voice note' : 'Voice note',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: fg,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
            ],
            Text(
              message.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: fg,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              time,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: fg.withValues(alpha: 0.55),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: dark ? BuddyColors.nightBuddyBubble : BuddyColors.bubbleBuddy,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          'Buddy is with you…',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: BuddyColors.sage,
                fontStyle: FontStyle.italic,
              ),
        ),
      ),
    );
  }
}
