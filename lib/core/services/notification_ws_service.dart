import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:async';

class NotificationWebSocketService {
  WebSocketChannel? _channel;
  StreamController<String>? _messageController;
  StreamController<bool>? _connectionStatusController;
  Timer? _reconnectTimer;
  bool _isConnecting = false;
  bool _shouldReconnect = true;
  int? _currentWorkerId;

  // Streams for external consumption
  Stream<String> get messageStream =>
      _messageController?.stream ?? Stream.empty();
  Stream<bool> get connectionStatusStream =>
      _connectionStatusController?.stream ?? Stream.empty();

  // Getters for current state
  bool get isConnected => _channel != null;
  bool get isConnecting => _isConnecting;

  void connect(int workerId) {
    print('[NotificationWS] Attempting to connect for workerId: $workerId');
    if (_isConnecting || (_channel != null && _currentWorkerId == workerId)) {
      print(
        '[NotificationWS] Already connecting or connected for workerId: $workerId',
      );
      return;
    }

    // Ensure controllers are initialized
    _ensureControllers();

    _currentWorkerId = workerId;
    _shouldReconnect = true;
    _connectInternal(workerId);
  }

  void _connectInternal(int workerId) {
    if (_isConnecting) return;

    _isConnecting = true;
    _updateConnectionStatus(false);

    try {
      final url = 'wss://myworkbee.duckdns.org/ws/notifications/$workerId';
      print('[NotificationWS] Connecting to: ' + url);

      _channel = WebSocketChannel.connect(Uri.parse(url));

      // Add a small delay to ensure connection is established
      Future.delayed(const Duration(milliseconds: 500), () {
        // Listen for messages
        _channel!.stream.listen(
          (message) {
            print('[NotificationWS] Received message: ' + message.toString());
            if (_messageController != null) {
              _messageController!.add(message.toString());
            }
          },
          onError: (error) {
            print('[NotificationWS] Connection error: ' + error.toString());
            _handleConnectionError();
          },
          onDone: () {
            print('[NotificationWS] Connection closed');
            _handleConnectionClosed();
          },
        );

        _isConnecting = false;
        _updateConnectionStatus(true);
        print(
          '[NotificationWS] Connection established for workerId: $workerId',
        );
      });
    } catch (e) {
      print('[NotificationWS] Exception during connect: ' + e.toString());
      _isConnecting = false;
      _updateConnectionStatus(false);
      _handleConnectionError();
    }
  }

  void _handleConnectionError() {
    _channel = null;
    _updateConnectionStatus(false);

    if (_shouldReconnect && _currentWorkerId != null) {
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(const Duration(seconds: 5), () {
        if (_shouldReconnect && _currentWorkerId != null) {
          _connectInternal(_currentWorkerId!);
        }
      });
    }
  }

  void _handleConnectionClosed() {
    _channel = null;
    _updateConnectionStatus(false);

    if (_shouldReconnect && _currentWorkerId != null) {
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(const Duration(seconds: 2), () {
        if (_shouldReconnect && _currentWorkerId != null) {
          _connectInternal(_currentWorkerId!);
        }
      });
    }
  }

  void _updateConnectionStatus(bool isConnected) {
    _connectionStatusController?.add(isConnected);
  }

  void disconnect() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _currentWorkerId = null;
    _isConnecting = false;

    if (_channel != null) {
      _channel!.sink.close(status.goingAway);
      _channel = null;
    }

    _updateConnectionStatus(false);
  }

  void dispose() {
    disconnect();
    _messageController?.close();
    _connectionStatusController?.close();
  }

  // Initialize controllers if not already done
  void _ensureControllers() {
    _messageController ??= StreamController<String>.broadcast();
    _connectionStatusController ??= StreamController<bool>.broadcast();
  }

  // Public method to ensure controllers are initialized
  void initialize() {
    _ensureControllers();
  }
}
