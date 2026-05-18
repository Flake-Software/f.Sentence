import 'package:home_widget/home_widget.dart';

class WidgetManager {
  static const String appGroupId = 'group.sentence.widgets';
  static const String uriScheme = 'sentence://add_note';

  /// Prepares click listeners inside the Flutter application environment
  static Future<void> setupWidgetClickListener(Function(Uri?) callback) async {
    await HomeWidget.setAppGroupId(appGroupId);
    HomeWidget.widgetClicked.listen(callback);
  }

  /// Sends the current list of note titles down to the Shared Preferences bucket
  /// and triggers a visual update check for the Native Notes List Widget.
  static Future<void> updateWidgetNotesList(List<String> titles) async {
    // Pipe-separate titles into a flat string format to send across the boundary
    final String flatTitles = titles.join("|");
    
    // Save locally under groupID shared storage key
    await HomeWidget.setAppGroupId(appGroupId);
    await HomeWidget.saveWidgetData<String>('note_titles', flatTitles);
    
    // Force native broadcast update event
    await HomeWidget.updateWidget(
      name: 'NotesListWidgetProvider', 
      androidName: 'NotesListWidgetProvider',
    );
  }
}