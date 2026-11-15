import 'package:flutter_test/flutter_test.dart';

import '../integration_test/habit_flow_test.dart';

void main() {
  LiveTestWidgetsFlutterBinding.ensureInitialized();
  runHabitFlowTests();
}
