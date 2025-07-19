import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';

class WebSocketConnectionWidget extends StatefulWidget {
  final Widget child;
  
  const WebSocketConnectionWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<WebSocketConnectionWidget> createState() => _WebSocketConnectionWidgetState();
}

class _WebSocketConnectionWidgetState extends State<WebSocketConnectionWidget> {
  bool _hasConnected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectToWebSocket();
    });
  }

  void _connectToWebSocket() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    
    if (authProvider.isWorker() && 
        authProvider.workerId != null && 
        !_hasConnected) {
      
      notificationProvider.connect(authProvider.workerId!);
      _hasConnected = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, NotificationProvider>(
      builder: (context, authProvider, notificationProvider, child) {
        // Auto-connect when worker logs in
        if (authProvider.isWorker() && 
            authProvider.workerId != null && 
            !_hasConnected) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _connectToWebSocket();
          });
        }

        // Disconnect when user logs out
        if (!authProvider.isLoggedIn && _hasConnected) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notificationProvider.disconnect();
            _hasConnected = false;
          });
        }

        return Stack(
          children: [
            widget.child,
            // Connection status indicator (smaller and better positioned)
            if (authProvider.isWorker() && authProvider.workerId != null)
              Positioned(
                top: MediaQuery.of(context).padding.top + 5,
                right: 5,
                child: _buildConnectionIndicator(notificationProvider),
              ),
          ],
        );
      },
    );
  }

  Widget _buildConnectionIndicator(NotificationProvider notificationProvider) {
    // Simple dot indicator to avoid screen overlap
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: notificationProvider.isConnected 
            ? Colors.green
            : notificationProvider.isConnecting
                ? Colors.orange
                : Colors.red,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
} 