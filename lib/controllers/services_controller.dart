import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class ServicesController extends GetxController {
  var services = [].obs;

  void addService(data) {
    services.add(data);
  }

  void deleteServices() {
    services.clear();
  }
}
