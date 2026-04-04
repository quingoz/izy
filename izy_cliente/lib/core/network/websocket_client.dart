import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/app_config.dart';

class WebSocketClient {
  static IO.Socket? _socket;

  static IO.Socket get instance {
    _socket ??= IO.io(
      AppConfig.wsUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    return _socket!;
  }

  static void connect() {
    instance.connect();
  }

  static void disconnect() {
    instance.disconnect();
  }

  static void subscribe(String channel, Function(dynamic) callback) {
    instance.on(channel, callback);
  }

  static void unsubscribe(String channel) {
    instance.off(channel);
  }

  static bool get isConnected => instance.connected;
}
