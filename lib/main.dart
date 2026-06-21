import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/api/subsonic_api.dart';
import 'features/auth/auth_provider.dart';
import 'features/player/player_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final api = SubsonicApi();
  runApp(
    MultiProvider(
      providers: [
        Provider<SubsonicApi>.value(value: api),
        ChangeNotifierProvider(create: (_) => AuthState(api)),
        ChangeNotifierProvider(create: (_) => PlayerState(api: api)),
      ],
      child: const App(),
    ),
  );
}
