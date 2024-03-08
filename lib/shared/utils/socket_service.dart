import 'package:socket_io_client/socket_io_client.dart';
import 'package:be_fast/api/constants/base_url.dart';

class SocketService {
  late Socket _socket;

  void initSocket() {
    _socket = io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.connect();
  }

  void disconnect() {
    _socket.disconnect();
  }

  void clearListeners() {
    _socket.clearListeners();
  }

  void emit(String event, dynamic data) {
    _socket.emit(event, data);
  }

  void on(String event, Function(dynamic) handler) {
    _socket.on(event, handler);
  }
}
