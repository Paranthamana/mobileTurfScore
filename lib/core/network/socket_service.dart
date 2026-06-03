import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import 'package:flutter/foundation.dart';

class SocketService {
  late socket_io.Socket _socket;

  void init() {
    _socket = socket_io.io('https://api.turfscore.example.com', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    _socket.onConnect((_) {
      if (kDebugMode) {
        print('Socket connected');
      }
    });

    _socket.onDisconnect((_) {
      if (kDebugMode) {
        print('Socket disconnected');
      }
    });
  }

  void connect() {
    _socket.connect();
  }

  void disconnect() {
    _socket.disconnect();
  }

  void joinRoom(String matchId) {
    _socket.emit('join_room', matchId);
  }

  void leaveRoom(String matchId) {
    _socket.emit('leave_room', matchId);
  }

  void onLiveScoreUpdated(Function(dynamic) callback) {
    _socket.on('live_score_updated', callback);
  }

  void onCommentary(Function(dynamic) callback) {
    _socket.on('commentary', callback);
  }
}
