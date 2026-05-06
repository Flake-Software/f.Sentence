import 'package:home_widget/home_widget.dart';

class WidgetManager {
  static const String appGroupId = 'group.sentence.widgets';
  static const String uriScheme = 'sentence://add_note';

  static Future<void> setupWidgetClickListener(Function(Uri?) callback) async {
    await HomeWidget.setAppGroupId(appGroupId);
    HomeWidget.widgetClicked.listen(callback);
  }
}