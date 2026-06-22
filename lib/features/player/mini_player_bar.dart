import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/api/subsonic_api.dart';
import 'player_provider.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerState>();
    if (!player.hasCurrent) return const SizedBox.shrink();

    final api = context.read<SubsonicApi>();

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/now-playing'),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              margin: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppColors.darkCard,
                image: (player.currentCoverArt?.isNotEmpty ?? false)
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(api.getCoverArtUrl(player.currentCoverArt!, size: 48)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (player.currentCoverArt?.isEmpty ?? true)
                  ? const Icon(Icons.music_note_rounded, size: 24, color: AppColors.textDarkMuted)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.currentTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    player.currentArtist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textDarkSecondary
                          : AppColors.textLightSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                player.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: AppColors.primary,
              ),
              onPressed: () => player.togglePlayPause(),
            ),
            IconButton(
              icon: const Icon(Icons.skip_next_rounded, size: 22),
              onPressed: () => player.next(),
              color: AppColors.textDarkSecondary,
            ),
            Tooltip(
              message: player.repeatMode == PlayerRepeatMode.all
                  ? '列表循环'
                  : player.repeatMode == PlayerRepeatMode.one
                      ? '单曲循环'
                      : '顺序播放',
              child: Icon(
                player.repeatMode == PlayerRepeatMode.one
                    ? Icons.repeat_one_on_rounded
                    : player.repeatMode == PlayerRepeatMode.all
                        ? Icons.repeat_on_rounded
                        : Icons.repeat_rounded,
                size: 16,
                color: player.repeatMode != PlayerRepeatMode.none
                    ? AppColors.primary
                    : AppColors.textDarkMuted,
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}
