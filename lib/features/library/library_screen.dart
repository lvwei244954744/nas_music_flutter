import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format_utils.dart';
import '../../core/api/subsonic_api.dart';
import '../../data/models/models.dart';
import '../auth/auth_provider.dart';
import '../player/player_provider.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('曲库'),
        actions: [
          IconButton(icon: const Icon(Icons.search_outlined), onPressed: () => Navigator.pushNamed(context, '/search')),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textDarkMuted,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [Tab(text: '歌手'), Tab(text: '专辑'), Tab(text: '歌单'), Tab(text: '歌曲')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_ArtistsTab(), _AlbumsTab(), _PlaylistsTab(), _SongsTab()],
      ),
    );
  }
}

class _ArtistsTab extends StatefulWidget {
  const _ArtistsTab();
  @override
  State<_ArtistsTab> createState() => _ArtistsTabState();
}

class _ArtistsTabState extends State<_ArtistsTab> {
  List<Artist>? _artists;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = context.read<AuthState>().api;
      final data = await api.getArtists();
      if (mounted) setState(() { _artists = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final data = _artists;
    if (data == null || data.isEmpty) return Center(child: Text('暂无歌手', style: Theme.of(context).textTheme.bodyMedium));

    final grouped = <String, List<Artist>>{};
    for (final artist in data) {
      final firstChar = artist.name.isNotEmpty ? artist.name[0].toUpperCase() : '?';
      grouped.putIfAbsent(firstChar, () => []).add(artist);
    }
    final sortedKeys = grouped.keys.toList()..sort();

    return ListView.builder(
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final letter = sortedKeys[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(letter, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary)),
            ),
            ...grouped[letter]!.map((artist) => ListTile(
              leading: CircleAvatar(backgroundColor: AppColors.darkCard, child: Text(artist.name.isNotEmpty ? artist.name[0] : '?', style: TextStyle(color: AppColors.primary))),
              title: Text(artist.name),
              subtitle: Text('${artist.albumCount ?? 0} 张专辑', style: Theme.of(context).textTheme.bodySmall),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () => Navigator.pushNamed(context, '/artist/${artist.id}'),
            )),
          ],
        );
      },
    );
  }
}

class _AlbumsTab extends StatefulWidget {
  const _AlbumsTab();
  @override
  State<_AlbumsTab> createState() => _AlbumsTabState();
}

class _AlbumsTabState extends State<_AlbumsTab> {
  List<Album>? _albums;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = context.read<AuthState>().api;
      final data = await api.getAlbumList(type: 'newest', size: 100);
      if (mounted) setState(() { _albums = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final data = _albums;
    if (data == null || data.isEmpty) return Center(child: Text('暂无专辑', style: Theme.of(context).textTheme.bodyMedium));

    final api = context.read<AuthState>().api;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.85, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemCount: data.length,
      itemBuilder: (context, index) => _AlbumGridItem(album: data[index], api: api),
    );
  }
}

class _PlaylistsTab extends StatefulWidget {
  const _PlaylistsTab();
  @override
  State<_PlaylistsTab> createState() => _PlaylistsTabState();
}

class _PlaylistsTabState extends State<_PlaylistsTab> {
  List<Playlist>? _playlists;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = context.read<AuthState>().api;
      final data = await api.getPlaylists();
      if (mounted) setState(() { _playlists = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final data = _playlists;
    if (data == null) return Center(child: Text('暂无歌单', style: Theme.of(context).textTheme.bodyMedium));

    return ListView.builder(
      itemCount: data.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, '/playlist/edit');
                  if (result == true) _load();
                },
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('新建歌单'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          );
        }
        final pl = data[index - 1];
        return ListTile(
          leading: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppColors.darkCard, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.playlist_play, color: AppColors.primary),
          ),
          title: Text(pl.name),
          subtitle: Text('${pl.songCount ?? 0} 首', style: Theme.of(context).textTheme.bodySmall),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz, size: 20, color: AppColors.textDarkMuted),
            onSelected: (v) async {
              if (v == 'edit') {
                final result = await Navigator.pushNamed(context, '/playlist/edit', arguments: {
                  'id': pl.id,
                  'name': pl.name,
                });
                if (result == true) _load();
              } else if (v == 'delete') {
                try {
                  final api = context.read<AuthState>().api;
                  await api.deletePlaylist(pl.id);
                  _load();
                } catch (_) {}
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_outlined, size: 20), title: Text('编辑'), dense: true)),
              const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error), title: Text('删除', style: TextStyle(color: AppColors.error)), dense: true)),
            ],
          ),
          onTap: () => Navigator.pushNamed(context, '/playlist/${pl.id}'),
        );
      },
    );
  }
}

class _SongsTab extends StatefulWidget {
  const _SongsTab();
  @override
  State<_SongsTab> createState() => _SongsTabState();
}

class _SongsTabState extends State<_SongsTab> {
  final List<Song> _songs = [];
  final ScrollController _scrollController = ScrollController();
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  static const int _pageSize = 50;

  @override
  void initState() {
    super.initState();
    _load();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200
        && !_loadingMore && _hasMore) {
      _loadMore();
    }
  }

  Future<void> _load() async {
    setState(() { _loading = true; _hasMore = true; _offset = 0; });
    try {
      final api = context.read<AuthState>().api;
      final data = await api.searchSongs(query: '', count: _pageSize, offset: 0);
      if (mounted) setState(() {
        _songs
          ..clear()
          ..addAll(data);
        _hasMore = data.length >= _pageSize;
        _offset = data.length;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _loadingMore) return;
    setState(() => _loadingMore = true);
    try {
      final api = context.read<AuthState>().api;
      final data = await api.searchSongs(query: '', count: _pageSize, offset: _offset);
      if (mounted) setState(() {
        _songs.addAll(data);
        _hasMore = data.length >= _pageSize;
        _offset += data.length;
        _loadingMore = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_songs.isEmpty) return Center(child: Text('暂无歌曲', style: Theme.of(context).textTheme.bodyMedium));

    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _songs.length + (_loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _songs.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          final song = _songs[index];
          return ListTile(
            leading: SizedBox(
              width: 40,
              child: Center(
                child: Text('${index + 1}', style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textDarkMuted)),
              ),
            ),
            title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(
              [song.artist, song.album].where((e) => e != null && e.isNotEmpty).join(' - '),
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
            trailing: song.duration != null
                ? Text(formatSeconds(song.duration!), style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textDarkMuted))
                : null,
            onTap: () {
              final player = context.read<PlayerState>();
              player.playList(_songs, startIndex: index);
            },
          );
        },
      ),
    );
  }
}

class _AlbumGridItem extends StatelessWidget {
  final Album album;
  final SubsonicApi api;
  const _AlbumGridItem({required this.album, required this.api});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/album/${album.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.darkCard,
                image: (album.coverArt?.isNotEmpty ?? false)
                    ? DecorationImage(image: NetworkImage(api.getCoverArtUrl(album.coverArt!)), fit: BoxFit.cover)
                    : null,
              ),
              child: (album.coverArt?.isEmpty ?? true)
                  ? Icon(Icons.album_outlined, size: 40, color: AppColors.textDarkMuted)
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(album.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyLarge?.copyWith(fontSize: 13)),
          Text(album.artist ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
