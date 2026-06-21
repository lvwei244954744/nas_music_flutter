import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/models.dart';
import '../auth/auth_provider.dart';
import '../player/player_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<Object>? _results;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() { _results = null; _error = null; });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () => _search(value.trim()));
  }

  Future<void> _search(String query) async {
    setState(() { _loading = true; _error = null; });
    try {
      final api = context.read<AuthState>().api;
      final data = await api.search(query);
      if (mounted) setState(() { _results = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
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

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController, autofocus: true, onChanged: _onSearchChanged,
          decoration: const InputDecoration(hintText: '搜索歌手、专辑、歌曲...', border: InputBorder.none, filled: false),
          style: theme.textTheme.bodyLarge,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); _onSearchChanged(''); }),
        ],
      ),
      body: _buildResults(theme),
    );
  }

  Widget _buildResults(ThemeData theme) {
    if (_searchController.text.trim().isEmpty) {
      return Center(child: Text('输入关键词搜索', style: theme.textTheme.bodyMedium));
    }
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text('搜索失败', style: theme.textTheme.bodyMedium));
    final data = _results;
    if (data == null || data.isEmpty) return Center(child: Text('未找到结果', style: theme.textTheme.bodyMedium));

    final api = context.read<AuthState>().api;
    final player = context.read<PlayerState>();
    final artists = data.whereType<Artist>().toList();
    final albums = data.whereType<Album>().toList();
    final songs = data.whereType<Song>().toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        if (artists.isNotEmpty) ...[
          Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: Text('歌手', style: theme.textTheme.headlineSmall)),
          ...artists.map((a) => ListTile(
            leading: CircleAvatar(backgroundColor: AppColors.darkCard, child: Text(a.name.isNotEmpty ? a.name[0] : '?', style: TextStyle(color: AppColors.primary))),
            title: Text(a.name),
            subtitle: Text('${a.albumCount ?? 0} 张专辑', style: theme.textTheme.bodySmall),
            onTap: () => Navigator.pushNamed(context, '/artist/${a.id}'),
          )),
        ],
        if (albums.isNotEmpty) ...[
          Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: Text('专辑', style: theme.textTheme.headlineSmall)),
          ...albums.map((a) => ListTile(
            leading: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6), color: AppColors.darkCard,
                image: (a.coverArt?.isNotEmpty ?? false)
                    ? DecorationImage(image: NetworkImage(api.getCoverArtUrl(a.coverArt!)), fit: BoxFit.cover)
                    : null,
              ),
              child: (a.coverArt?.isEmpty ?? true) ? Icon(Icons.album_outlined, size: 24, color: AppColors.textDarkMuted) : null,
            ),
            title: Text(a.name),
            subtitle: Text(a.artist ?? '', style: theme.textTheme.bodySmall),
            onTap: () => Navigator.pushNamed(context, '/album/${a.id}'),
          )),
        ],
        if (songs.isNotEmpty) ...[
          Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), child: Text('歌曲', style: theme.textTheme.headlineSmall)),
          ...songs.map((s) => ListTile(
            leading: Icon(Icons.music_note_outlined, color: AppColors.textDarkMuted),
            title: Text(s.title),
            subtitle: Text('${s.artist ?? ''} · ${s.album ?? ''}', style: theme.textTheme.bodySmall),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_formatDuration(s.duration ?? 0), style: theme.textTheme.bodySmall),
                IconButton(
                  icon: const Icon(Icons.playlist_add_rounded, size: 20),
                  onPressed: () {
                    player.addToQueue(s);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已加入队列'), duration: Duration(seconds: 1)),
                    );
                  },
                  color: AppColors.textDarkMuted,
                ),
              ],
            ),
            onTap: () {
              final songsOnly = songs.map((e) => e).toList();
              final idx = songs.indexOf(s);
              player.playList(songsOnly, startIndex: idx);
            },
          )),
        ],
      ],
    );
  }
}
