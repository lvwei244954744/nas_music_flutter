import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../auth/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _starredCount = 0;
  int _frequentCount = 0;
  int _songCount = 0;
  bool _statsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<int> _countSongs() async {
    final api = context.read<AuthState>().api;
    const pageSize = 500;
    int total = 0;
    while (true) {
      final batch = await api.searchSongs(query: '', count: pageSize, offset: total);
      total += batch.length;
      if (batch.length < pageSize) break;
    }
    return total;
  }

  Future<int> _countAlbums(String type) async {
    final api = context.read<AuthState>().api;
    const pageSize = 500;
    int total = 0;
    while (true) {
      final batch = await api.getAlbumList(type: type, size: pageSize, offset: total);
      total += batch.length;
      if (batch.length < pageSize) break;
    }
    return total;
  }

  Future<void> _loadStats() async {
    try {
      final api = context.read<AuthState>().api;
      final results = await Future.wait([
        api.getStarred(),
        _countAlbums('frequent'),
        _countSongs(),
      ], eagerError: false);
      if (mounted) {
        setState(() {
          _starredCount = (results[0] as List).length;
          _frequentCount = results[1] as int;
          _songCount = results[2] as int;
          _statsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _statsLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Icon(Icons.person_rounded, size: 28, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(auth.username ?? '未登录', style: theme.textTheme.titleMedium),
                    if (auth.serverUrl != null)
                      Text(auth.serverUrl!, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textDarkMuted)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_statsLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _StatCard(icon: Icons.play_circle_outline, label: '播放', value: '$_frequentCount'),
                  const SizedBox(width: 12),
                  _StatCard(icon: Icons.star_outline, label: '收藏', value: '$_starredCount'),
                  const SizedBox(width: 12),
                  _StatCard(icon: Icons.music_note_outlined, label: '歌曲', value: '$_songCount'),
                ],
              ),
            ),
          const SizedBox(height: 8),
          const _Divider(),
          _SectionTitle(title: '服务器'),
          _SettingTile(icon: Icons.dns_outlined, title: '服务器地址', subtitle: auth.serverUrl ?? '未连接'),
          if (auth.username != null) _SettingTile(icon: Icons.person_outline, title: '当前用户', subtitle: auth.username!),
          const _Divider(),
          _SectionTitle(title: '关于'),
          _SettingTile(icon: Icons.info_outline, title: '版本', subtitle: '1.0.0'),
          const _Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.read<AuthState>().logout();
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('断开连接'),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textDarkMuted)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  const _SettingTile({required this.icon, required this.title, this.subtitle});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: subtitle != null ? Text(subtitle!, style: Theme.of(context).textTheme.bodySmall) : null,
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Divider(height: 1, color: AppColors.darkBorder);
}
