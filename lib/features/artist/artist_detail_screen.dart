import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/models.dart';
import '../auth/auth_provider.dart';

class ArtistDetailScreen extends StatefulWidget {
  final String artistId;
  const ArtistDetailScreen({super.key, required this.artistId});

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  Artist? _artist;
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
      final results = await Future.wait([
        api.getArtist(widget.artistId),
        api.getArtistAlbums(widget.artistId),
      ]);
      if (mounted) setState(() { _artist = results[0] as Artist; _albums = results[1] as List<Album>; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) return Scaffold(appBar: AppBar(title: const Text('歌手')), body: const Center(child: CircularProgressIndicator()));

    final a = _artist;
    final data = _albums;
    if (a == null) return Scaffold(appBar: AppBar(title: const Text('歌手')), body: const Center(child: Text('加载失败')));
    final api = context.read<AuthState>().api;

    return Scaffold(
      appBar: AppBar(title: const Text('歌手')),
      body: data == null
          ? const Center(child: Text('加载失败'))
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(radius: 40, backgroundColor: AppColors.darkCard, child: Text(a.name.isNotEmpty ? a.name[0] : '?', style: const TextStyle(fontSize: 32, color: AppColors.primary))),
                        const SizedBox(width: 16),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(a.name, style: theme.textTheme.headlineMedium),
                          Text('${a.albumCount ?? 0} 张专辑', style: theme.textTheme.bodySmall),
                        ]),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 8), child: Text('专辑', style: theme.textTheme.headlineSmall))),
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.85, crossAxisSpacing: 12, mainAxisSpacing: 12),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final album = data[index];
                      return GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/album/${album.id}'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8), color: AppColors.darkCard,
                                  image: (album.coverArt?.isNotEmpty ?? false) ? DecorationImage(image: NetworkImage(api.getCoverArtUrl(album.coverArt!)), fit: BoxFit.cover) : null,
                                ),
                                child: (album.coverArt?.isEmpty ?? true) ? Icon(Icons.album_outlined, size: 40, color: AppColors.textDarkMuted) : null,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(album.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyLarge?.copyWith(fontSize: 13)),
                            if (album.year != null) Text(album.year.toString(), style: theme.textTheme.bodySmall),
                          ],
                        ),
                      );
                    },
                    childCount: data.length,
                  ),
                ),
              ],
            ),
    );
  }
}
