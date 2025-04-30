import 'dart:async';

class NotificationService {
  final _controllers = <String, StreamController>{};

  void notify(String event, [dynamic data]) {
    if (!_controllers.containsKey(event)) {
      _controllers[event] = StreamController.broadcast();
    }
    _controllers[event]!.add(data ?? event);
  }

  void addListener(String event, Function(dynamic) callback) {
    if (!_controllers.containsKey(event)) {
      _controllers[event] = StreamController.broadcast();
    }
    _controllers[event]!.stream.listen(callback);
  }

  void removeListener(String event) {
    _controllers[event]?.close();
    _controllers.remove(event);
  }

  void dispose() {
    for (var controller in _controllers.values) {
      controller.close();
    }
    _controllers.clear();
  }
}
