import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/api/subsonic_api.dart';
import '../../data/models/models.dart';
import '../auth/auth_provider.dart';
import '../player/player_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Album> _newest = [];
  List<Album> _random = [];
  List<Album> _recent = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final api = context.read<AuthState>().api;
      final results = await Future.wait([
        api.getAlbumList(type: 'newest', size: 20),
        api.getAlbumList(type: 'random', size: 10),
        api.getAlbumList(type: 'recent', size: 10),
      ]);
      if (mounted) {
        setState(() {
          _newest = results[0];
          _random = results[1];
          _recent = results[2];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final api = context.read<SubsonicApi>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
        actions: [
          IconButton(icon: const Icon(Icons.search_outlined), onPressed: () => Navigator.pushNamed(context, '/search')),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 80),
                children: [
                  _SectionHeader(title: '最新专辑', onSeeAll: () => Navigator.pushNamed(context, '/library')),
                  _AlbumRow(albums: _newest, api: api),
                  const SizedBox(height: 24),
                  _SectionHeader(title: '随机推荐'),
                  _AlbumRow(albums: _random, api: api),
                  const SizedBox(height: 24),
                  _SectionHeader(title: '最近播放'),
                  _AlbumRow(albums: _recent, api: api),
                ],
              ),
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const Spacer(),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text('查看全部', style: TextStyle(color: AppColors.primary, fontSize: 13)),
            ),
        ],
      ),
    );
  }
}

class _AlbumRow extends StatelessWidget {
  final List<Album> albums;
  final SubsonicApi api;
  const _AlbumRow({required this.albums, required this.api});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: albums.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _AlbumCard(album: albums[index], api: api),
      ),
    );
  }
}

class _AlbumCard extends StatelessWidget {
  final Album album;
  final SubsonicApi api;
  const _AlbumCard({required this.album, required this.api});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/album/${album.id}'),
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.darkCard,
                  image: (album.coverArt?.isNotEmpty ?? false)
                      ? DecorationImage(image: NetworkImage(api.getCoverArtUrl(album.coverArt!)), fit: BoxFit.cover)
                      : null,
                ),
                child: Stack(
                  children: [
                    if (album.coverArt?.isEmpty ?? true)
                      const Center(child: Icon(Icons.album_outlined, size: 40, color: AppColors.textDarkMuted)),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.play_arrow_rounded, size: 18),
                          color: Colors.white,
                          onPressed: () async {
                            final api = context.read<SubsonicApi>();
                            try {
                              final songs = await api.getAlbumSongs(album.id);
                              if (context.mounted) {
                                context.read<PlayerState>().playList(songs, startIndex: 0);
                              }
                            } catch (e) {
                              debugPrint('[HomeScreen] Failed to load songs: $e');
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(album.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyLarge?.copyWith(fontSize: 13)),
            Text(album.artist ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
