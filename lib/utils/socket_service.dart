import 'package:socket_io_client/socket_io_client.dart';
import 'package:be_fast/api/constants/base_url.dart';

class SocketService {
  late Socket socket;

  void initSocket() {
    socket = io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket.connect();
  }

  void dispose() {
    socket.disconnect();
  }

  void emit(String event, dynamic data) {
    socket.emit(event, data);
  }

  void on(String event, Function(dynamic) handler) {
    socket.on(event, handler);
  }
}
