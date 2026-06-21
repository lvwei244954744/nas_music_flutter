import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/api/subsonic_api.dart';
import 'player_provider.dart';

class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final player = context.watch<PlayerState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('播放队列'),
        actions: [
          if (player.queue.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => player.clearQueue(),
              tooltip: '清空队列',
            ),
        ],
      ),
      body: player.queue.isEmpty
          ? Center(child: Text('队列为空', style: theme.textTheme.bodyMedium))
          : ReorderableListView.builder(
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
                    onTap: () => player.playList(player.queue, startIndex: index),
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
            ),
    );
  }
}
