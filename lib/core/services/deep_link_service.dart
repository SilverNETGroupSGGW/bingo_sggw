import 'dart:async';
import 'package:app_links/app_links.dart';

class DeepLinkService {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  void initDeepLinks(Function(String roomId) onRoomIdReceived) async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri, onRoomIdReceived);
      }
    } catch (e) {
    }

    _sub = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleUri(uri, onRoomIdReceived);
      },
      onError: (err) {
      },
    );
  }

  void _handleUri(Uri uri, Function(String roomId) onRoomIdReceived) {
    final String? roomId = uri.queryParameters['room'];
    
    if (roomId != null && roomId.isNotEmpty) {
      onRoomIdReceived(roomId);
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}