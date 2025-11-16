import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'auth_service.dart';

class WebSocketService {
  static WebSocketChannel? _channel;
  static Function(Map<String, dynamic>)? _onDeviceUpdate;
  static Function(Map<String, dynamic>)? _onScheduleUpdate;

  static void connect({
    required Function(Map<String, dynamic>) onDeviceUpdate,
    Function(Map<String, dynamic>)? onScheduleUpdate,
  }) {
    _onDeviceUpdate = onDeviceUpdate;
    _onScheduleUpdate = onScheduleUpdate;

    final wsUrl = 'ws://192.168.2.149:8000/ws/devices/'; // Thay IP cho WebSocket
    print('🔌 Connecting to WebSocket: $wsUrl');

    _channel = IOWebSocketChannel.connect(wsUrl);

    _channel!.stream.listen(
          (message) {
        print('📡 WebSocket message received: $message');
        try {
          final data = json.decode(message);
          if (data['type'] == 'device_update') {
            _onDeviceUpdate?.call(data['device']);
          } else if (data['type'] == 'schedule_update') {
            _onScheduleUpdate?.call(data['schedule']);
          }
        } catch (e) {
          print('❌ WebSocket message parse error: $e');
        }
      },
      onError: (error) {
        print('❌ WebSocket error: $error');
        // Có thể thêm logic reconnect ở đây
      },
      onDone: () {
        print('🔌 WebSocket disconnected');
      },
    );
  }

  static void disconnect() {
    _channel?.sink.close();
    _channel = null;
    print('🔌 WebSocket disconnected manually');
  }

  static void sendMessage(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(json.encode(message));
    }
  }
}