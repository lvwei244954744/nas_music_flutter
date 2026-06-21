import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/models.dart';
import '../auth/auth_provider.dart';
import '../player/player_provider.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final String playlistId;
  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  List<Song>? _songs;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = context.read<AuthState>().api;
      final data = await api.getPlaylistSongs(widget.playlistId);
      if (mounted) setState(() { _songs = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) {
      return Scaffold(appBar: AppBar(title: const Text('歌单')), body: const Center(child: CircularProgressIndicator()));
    }

    final data = _songs;
    if (data == null) {
      return Scaffold(appBar: AppBar(title: const Text('歌单')), body: const Center(child: Text('加载失败')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('歌单'),
        actions: [
          if (data.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.play_arrow_rounded),
              onPressed: () {
                context.read<PlayerState>().playList(data.map((e) => e).toList(), startIndex: 0);
              },
              tooltip: '播放全部',
            ),
        ],
      ),
      body: data.isEmpty
          ? Center(child: Text('歌单为空', style: theme.textTheme.bodyMedium))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: data.length,
              separatorBuilder: (_, _) => Divider(height: 1, color: AppColors.darkBorder),
              itemBuilder: (context, index) {
                final song = data[index];
                return ListTile(
                  leading: SizedBox(
                    width: 24,
                    child: Text('${index + 1}', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textDarkMuted)),
                  ),
                  title: Text(song.title, style: const TextStyle(fontSize: 14)),
                  subtitle: Text('${song.artist ?? ''} · ${song.album ?? ''}', style: theme.textTheme.bodySmall),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz, size: 20, color: AppColors.textDarkMuted),
                    onSelected: (v) {
                      if (v == 'play') {
                        context.read<PlayerState>().playList(data.map((e) => e).toList(), startIndex: index);
                      } else if (v == 'next') {
                        context.read<PlayerState>().addToQueueNext(song);
                      } else if (v == 'queue') {
                        context.read<PlayerState>().addToQueue(song);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'play', child: ListTile(leading: Icon(Icons.play_arrow_rounded, size: 20), title: Text('播放'), dense: true)),
                      const PopupMenuItem(value: 'next', child: ListTile(leading: Icon(Icons.skip_next_rounded, size: 20), title: Text('下一首播放'), dense: true)),
                      const PopupMenuItem(value: 'queue', child: ListTile(leading: Icon(Icons.queue_music_rounded, size: 20), title: Text('加入队列'), dense: true)),
                    ],
                  ),
                  onTap: () {
                    context.read<PlayerState>().playList(data.map((e) => e).toList(), startIndex: index);
                  },
                );
              },
            ),
    );
  }
}
