import 'package:get/get.dart';
import 'package:infinite_tic_tac_toe/screens/game.page.dart';

class RouteName {
  static const game = "/";
}

List<GetPage<dynamic>> appRoutes = [
  GetPage(
      name: RouteName.game,
      page: () => const GameScreen(),
      transition: Transition.cupertino)
];
