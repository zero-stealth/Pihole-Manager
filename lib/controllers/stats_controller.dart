import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class StatsController extends GetxController {
  var topAds = [].obs;
  var topClients = [].obs;
  var topBlocked = [].obs;

  void addTopAds(data) {
    topAds.add(data);
  }

  void addTopClients(data) {
    topClients.add(data);
  }

  void addTopBlocked(data) {
    topBlocked.add(data);
  }

  void deleteStats() {
    topAds.clear();
    topClients.clear();
    topBlocked.clear();
  }
}
