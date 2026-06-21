import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../auth/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
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
                onPressed: () async {
                  await context.read<AuthState>().logout();
                  if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
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
