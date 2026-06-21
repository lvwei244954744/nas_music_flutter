import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/api/subsonic_api.dart';
import '../auth/auth_provider.dart';

class PlaylistEditScreen extends StatefulWidget {
  final String? playlistId;
  final String? initialName;

  const PlaylistEditScreen({
    super.key,
    this.playlistId,
    this.initialName,
  });

  @override
  State<PlaylistEditScreen> createState() => _PlaylistEditScreenState();
}

class _PlaylistEditScreenState extends State<PlaylistEditScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final api = context.read<AuthState>().api;
      if (widget.playlistId != null) {
        await api.updatePlaylist(widget.playlistId!, name: _nameController.text.trim());
      } else {
        await api.createPlaylist(_nameController.text.trim());
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.playlistId != null ? '歌单已更新' : '歌单已创建')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.playlistId == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? '新建歌单' : '编辑歌单'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('保存'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: '歌单名称',
                  hintText: '输入歌单名称',
                ),
                validator: (v) => v == null || v.trim().isEmpty ? '请输入歌单名称' : null,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _save(),
              ),
              const SizedBox(height: 24),
              if (!isNew && widget.playlistId != null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('删除歌单'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('确认删除'),
        content: const Text('删除后无法恢复，确定要删除这个歌单吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              final api = context.read<AuthState>().api;
              Navigator.pop(ctx);
              _performDelete(api);
            },
            child: const Text('删除', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete(SubsonicApi api) async {
    try {
      await api.deletePlaylist(widget.playlistId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('歌单已删除')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e')),
        );
      }
    }
  }
}
