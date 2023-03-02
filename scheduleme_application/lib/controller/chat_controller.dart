import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:scheduleme_application/models/message.dart';

class ChatController extends GetxController {
  var chatMessage = <Message>[].obs;
  var connectedUser = 0.obs;
}
