import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class LogsController extends GetxController {
  var logs = [].obs;
  var logsHistory = [].obs;

  void addLog(data) {
    logs.add(data);
  }

  void addLogHistory(data) {
    logsHistory.add(data);
  }

  void deleteLogs() {
    logs.clear();
    logsHistory.clear();
  }
}
