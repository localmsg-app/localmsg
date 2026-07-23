import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/device_list_screen.dart';
import 'services/chat_server.dart';
import 'services/chat_store.dart';
import 'services/device_identity_service.dart';
import 'services/discovery_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final identity = DeviceIdentityService();
  await identity.load();

  final chatStore = ChatStore();
  final chatServer = ChatServer(chatStore: chatStore);
  await chatServer.start();

  final discovery = DiscoveryService(
    identity: identity,
    servicePort: () => chatServer.port,
  );
  await discovery.start();

  runApp(
    LocalMsgApp(identity: identity, discovery: discovery, chatStore: chatStore),
  );
}

class LocalMsgApp extends StatelessWidget {
  final DeviceIdentityService identity;
  final DiscoveryService discovery;
  final ChatStore chatStore;

  const LocalMsgApp({
    super.key,
    required this.identity,
    required this.discovery,
    required this.chatStore,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: identity),
        ChangeNotifierProvider.value(value: discovery),
        ChangeNotifierProvider.value(value: chatStore),
      ],
      child: MaterialApp(
        title: 'LocalMsg',
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        darkTheme: ThemeData(
          colorSchemeSeed: Colors.indigo,
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        home: const DeviceListScreen(),
      ),
    );
  }
}
