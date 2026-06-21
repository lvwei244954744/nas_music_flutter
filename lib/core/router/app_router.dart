import 'package:flutter/material.dart';
import '../../features/auth/login_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/album/album_detail_screen.dart';
import '../../features/artist/artist_detail_screen.dart';
import '../../features/playlist/playlist_edit_screen.dart';
import '../../features/playlist/playlist_detail_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/player/now_playing_screen.dart';
import '../../features/settings/settings_screen.dart';

class AppRouter {
  static const login = '/login';
  static const home = '/home';
  static const library = '/library';
  static const search = '/search';
  static const nowPlaying = '/now-playing';
  static const settings = '/settings';
  static String album(String id) => '/album/$id';
  static String artist(String id) => '/artist/$id';
  static String playlist(String id) => '/playlist/$id';
  static const playlistEdit = '/playlist/edit';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '/');

    switch (uri.path) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/library':
        return MaterialPageRoute(builder: (_) => const LibraryScreen());
      case '/search':
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case '/now-playing':
        return MaterialPageRoute(builder: (_) => const NowPlayingScreen());
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        if (uri.path.startsWith('/album/')) {
          final id = uri.pathSegments.last;
          return MaterialPageRoute(builder: (_) => AlbumDetailScreen(albumId: id));
        }
        if (uri.path.startsWith('/artist/')) {
          final id = uri.pathSegments.last;
          return MaterialPageRoute(builder: (_) => ArtistDetailScreen(artistId: id));
        }
        if (uri.path == '/playlist/edit') {
          final args = settings.arguments as Map<String, String>?;
          return MaterialPageRoute(
            builder: (_) => PlaylistEditScreen(
              playlistId: args?['id'],
              initialName: args?['name'],
            ),
          );
        }
        if (uri.path.startsWith('/playlist/')) {
          final id = uri.pathSegments.last;
          return MaterialPageRoute(builder: (_) => PlaylistDetailScreen(playlistId: id));
        }
        return MaterialPageRoute(builder: (_) => const HomeScreen());
    }
  }
}
