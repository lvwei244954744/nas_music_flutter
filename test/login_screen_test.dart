import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:loml_nas_music/features/auth/login_screen.dart';
import 'package:loml_nas_music/features/auth/auth_provider.dart';
import 'package:loml_nas_music/core/api/subsonic_api.dart';

void main() {
  testWidgets('LoginScreen renders form fields', (WidgetTester tester) async {
    final api = SubsonicApi();
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => AuthState(api),
          child: const LoginScreen(),
        ),
      ),
    );

    expect(find.text('NasMusic'), findsOneWidget);
    expect(find.text('连接你的 Navidrome 服务器'), findsOneWidget);
    expect(find.text('服务器地址'), findsOneWidget);
    expect(find.text('用户名'), findsOneWidget);
    expect(find.text('密码'), findsOneWidget);
    expect(find.text('连接服务器'), findsOneWidget);
  });
}
