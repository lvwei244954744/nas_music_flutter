import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/api/subsonic_api.dart';
import '../../data/models/models.dart';
import '../auth/auth_provider.dart';
import '../player/player_provider.dart';

class AlbumDetailScreen extends StatefulWidget {
  final String albumId;
  const AlbumDetailScreen({super.key, required this.albumId});

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  Album? _album;
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
      final results = await Future.wait([
        api.getAlbum(widget.albumId),
        api.getAlbumSongs(widget.albumId),
      ]);
      if (mounted) {
        setState(() {
          _album = results[0] as Album;
          _songs = results[1] as List<Song>;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatDuration(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) {
      return Scaffold(appBar: AppBar(title: const Text('专辑')), body: const Center(child: CircularProgressIndicator()));
    }

    final a = _album;
    final s = _songs;
    if (a == null) {
      return Scaffold(appBar: AppBar(title: const Text('专辑')), body: const Center(child: Text('加载失败')));
    }
    final api = context.read<SubsonicApi>();

    return Scaffold(
      appBar: AppBar(title: const Text('专辑')),
      body: s == null
          ? const Center(child: Text('加载失败'))
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 140, height: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: AppColors.darkCard,
                            image: (a.coverArt?.isNotEmpty ?? false)
                                ? DecorationImage(image: CachedNetworkImageProvider(api.getCoverArtUrl(a.coverArt!, size: 300)), fit: BoxFit.cover)
                                : null,
                          ),
                          child: (a.coverArt?.isEmpty ?? true)
                              ? Icon(Icons.album_outlined, size: 50, color: AppColors.textDarkMuted)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.name, style: theme.textTheme.headlineMedium),
                              const SizedBox(height: 4),
                              Text(a.artist ?? '', style: theme.textTheme.bodyLarge),
                              const SizedBox(height: 8),
                              Text(
                                '${a.year ?? ''} · ${a.songCount ?? 0} 首 · ${_formatDuration(a.duration ?? 0)}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        FilledButton.icon(
                          onPressed: () {
                            if (s.isNotEmpty) {
                              context.read<PlayerState>().playList(s.map((e) => e).toList(), startIndex: 0);
                            }
                          },
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('播放全部'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            if (s.isNotEmpty) {
                              final shuffled = List<Song>.from(s);
                              shuffled.shuffle();
                              context.read<PlayerState>().playList(shuffled, startIndex: 0);
                            }
                          },
                          icon: const Icon(Icons.shuffle_rounded),
                          label: const Text('随机播放'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: Divider(color: AppColors.darkBorder)),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final song = s[index];
                      return ListTile(
                        leading: SizedBox(
                          width: 24,
                          child: Text('${index + 1}', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textDarkMuted)),
                        ),
                        title: Text(song.title, style: const TextStyle(fontSize: 14)),
                        subtitle: Text(song.artist ?? '', style: theme.textTheme.bodySmall),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_formatDuration(song.duration ?? 0), style: theme.textTheme.bodySmall),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              key: ValueKey('album_song_menu_${song.id}'),
                              icon: const Icon(Icons.more_horiz, size: 20, color: AppColors.textDarkMuted),
                              onSelected: (v) {
                                if (v == 'play') {
                                  context.read<PlayerState>().playList(s.map((e) => e).toList(), startIndex: index);
                                } else if (v == 'next') {
                                  context.read<PlayerState>().addToQueueNext(song);
                                } else if (v == 'queue') {
                                  context.read<PlayerState>().addToQueue(song);
                                } else if (v == 'playlist') {
                                  _addToPlaylist(context, song.id);
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(value: 'play', child: ListTile(leading: Icon(Icons.play_arrow_rounded, size: 20), title: Text('播放'), dense: true)),
                                const PopupMenuItem(value: 'next', child: ListTile(leading: Icon(Icons.skip_next_rounded, size: 20), title: Text('下一首播放'), dense: true)),
                                const PopupMenuItem(value: 'queue', child: ListTile(leading: Icon(Icons.queue_music_rounded, size: 20), title: Text('加入队列'), dense: true)),
                                const PopupMenuItem(value: 'playlist', child: ListTile(leading: Icon(Icons.playlist_add_rounded, size: 20), title: Text('添加到歌单'), dense: true)),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          context.read<PlayerState>().playList(s.map((e) => e).toList(), startIndex: index);
                        },
                      );
                    },
                    childCount: s.length,
                  ),
                ),
              ],
            ),
    );
  }
}

Future<void> _addToPlaylist(BuildContext context, String songId) async {
  final api = context.read<SubsonicApi>();
  List<Playlist> playlists;
  try {
    playlists = await api.getPlaylists();
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('加载歌单失败: $e')));
    }
    return;
  }

  if (!context.mounted) return;
  if (playlists.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('暂无歌单，请先创建')),
    );
    return;
  }

  final selected = await showDialog<String>(
    context: context,
    builder: (ctx) => SimpleDialog(
      backgroundColor: AppColors.darkSurface,
      title: const Text('添加到歌单'),
      children: playlists.map((pl) => SimpleDialogOption(
        onPressed: () => Navigator.pop(ctx, pl.id),
        child: ListTile(
          leading: const Icon(Icons.playlist_play_rounded, color: AppColors.primary),
          title: Text(pl.name),
          dense: true,
          contentPadding: EdgeInsets.zero,
        ),
      )).toList(),
    ),
  );

  if (selected == null) return;
  if (!context.mounted) return;

  try {
    await api.updatePlaylist(selected, songIdsToAdd: [songId]);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已添加到歌单')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('添加失败: $e')));
    }
  }
}
