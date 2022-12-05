import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class DevicesController extends GetxController {
  var devices = [].obs;

  void addDevice(data) {
    devices.add(data);
  }

  void deleteDevices() {
    devices.clear();
  }
}
