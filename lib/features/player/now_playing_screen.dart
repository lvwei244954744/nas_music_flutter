import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/api/subsonic_api.dart';
import 'player_provider.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  bool _showQueue = false;

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerState>();
    final theme = Theme.of(context);
    final api = context.read<SubsonicApi>();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _showQueue ? '播放队列' : (player.currentArtist.isNotEmpty ? player.currentArtist : '未在播放'),
          style: theme.textTheme.titleSmall,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_showQueue ? Icons.album_outlined : Icons.queue_music_outlined),
            onPressed: () => setState(() => _showQueue = !_showQueue),
          ),
        ],
      ),
      body: _showQueue ? _QueueView(player: player) : _PlayerView(player: player, api: api, theme: theme),
    );
  }
}

class _PlayerView extends StatelessWidget {
  final PlayerState player;
  final SubsonicApi api;
  final ThemeData theme;

  const _PlayerView({required this.player, required this.api, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 1),
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.darkCard,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 60,
                  spreadRadius: 10,
                ),
              ],
              image: (player.currentCoverArt?.isNotEmpty ?? false)
                  ? DecorationImage(
                      image: NetworkImage(api.getCoverArtUrl(player.currentCoverArt!, size: 300)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: (player.currentCoverArt?.isEmpty ?? true)
                ? const Center(child: Icon(Icons.music_note_rounded, size: 80, color: AppColors.primary))
                : null,
          ),
          const Spacer(flex: 1),
          Text(
            player.currentTitle.isNotEmpty ? player.currentTitle : '未在播放',
            style: theme.textTheme.headlineMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            player.currentArtist.isNotEmpty ? player.currentArtist : '选择一首歌曲开始播放',
            style: theme.textTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.darkBorder,
              thumbColor: AppColors.primary,
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: player.progress,
              onChanged: player.hasCurrent ? (v) => player.seekTo(v) : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(player.position), style: theme.textTheme.bodySmall),
                Text(_formatDuration(player.duration), style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  player.isShuffled ? Icons.shuffle_on_rounded : Icons.shuffle_rounded,
                ),
                onPressed: player.hasCurrent ? () => player.toggleShuffle() : null,
                color: player.isShuffled ? AppColors.primary : AppColors.textDarkMuted,
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded, size: 32),
                onPressed: player.hasCurrent ? () => player.previous() : null,
                color: AppColors.textDarkSecondary,
              ),
              const SizedBox(width: 16),
              Container(
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                child: IconButton(
                  icon: Icon(
                    player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 36,
                  ),
                  onPressed: player.hasCurrent ? () => player.togglePlayPause() : null,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded, size: 32),
                onPressed: player.hasCurrent ? () => player.next() : null,
                color: AppColors.textDarkSecondary,
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(
                  player.repeatMode == PlayerRepeatMode.one
                      ? Icons.repeat_one_on_rounded
                      : player.repeatMode == PlayerRepeatMode.all
                          ? Icons.repeat_on_rounded
                          : Icons.repeat_rounded,
                ),
                onPressed: player.hasCurrent ? () => player.cyclePlayerRepeatMode() : null,
                color: player.repeatMode != PlayerRepeatMode.none ? AppColors.primary : AppColors.textDarkMuted,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.favorite_border_rounded),
                onPressed: null,
                color: AppColors.textDarkMuted,
              ),
              IconButton(
                icon: const Icon(Icons.lyrics_outlined),
                onPressed: null,
                color: AppColors.textDarkMuted,
              ),
              IconButton(
                icon: const Icon(Icons.playlist_play_rounded),
                onPressed: null,
                color: AppColors.textDarkMuted,
              ),
              IconButton(
                icon: const Icon(Icons.volume_up_outlined),
                onPressed: null,
                color: AppColors.textDarkMuted,
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final min = d.inMinutes;
    final sec = d.inSeconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}

class _QueueView extends StatelessWidget {
  final PlayerState player;
  const _QueueView({required this.player});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (player.queue.isEmpty) {
      return Center(child: Text('队列为空', style: theme.textTheme.bodyMedium));
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: player.queue.length,
      onReorderItem: (old, new_) => player.reorderQueue(old, new_),
      itemBuilder: (context, index) {
        final song = player.queue[index];
        final isCurrent = index == player.currentIndex;
        final api = context.read<SubsonicApi>();

        return Container(
          key: ValueKey('${song.id}_$index'),
          decoration: BoxDecoration(
            color: isCurrent ? AppColors.primary.withValues(alpha: 0.08) : null,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
                width: 0.5,
              ),
            ),
          ),
          child: ListTile(
            onTap: () {
              player.playList(player.queue, startIndex: index);
            },
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle, size: 20, color: AppColors.textDarkMuted),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: AppColors.darkCard,
                    image: (song.coverArt?.isNotEmpty ?? false)
                        ? DecorationImage(image: NetworkImage(api.getCoverArtUrl(song.coverArt!)), fit: BoxFit.cover)
                        : null,
                  ),
                  child: (song.coverArt?.isEmpty ?? true)
                      ? Icon(Icons.music_note_outlined, size: 20, color: AppColors.textDarkMuted)
                      : null,
                ),
              ],
            ),
            title: Text(
              song.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                color: isCurrent ? AppColors.primary : null,
              ),
            ),
            subtitle: Text(song.artist ?? '', style: theme.textTheme.bodySmall),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () => player.removeFromQueue(index),
              color: AppColors.textDarkMuted,
            ),
          ),
        );
      },
    );
  }
}
