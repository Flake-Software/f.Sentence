import 'package:home_widget/home_widget.dart';
import 'package:flutter/material.dart';

class WidgetManager {
  static const String androidWidgetName = 'AddNoteWidget'; // Must match Android XML
  static const String addNoteGroup = 'group.sentence.widgets';

  /// Sets up the listener for widget clicks
  static Future<void> setupWidgetClickListener(Function(Uri?) callback) async {
    HomeWidget.setAppGroupId(addNoteGroup);
    HomeWidget.registerInteractivityCallback(interactiveCallback);
    
    // Listen for the URI that triggered the app open
    HomeWidget.initiallyLaunchedFromHomeWidget().then(callback);
    HomeWidget.widgetClicked.listen(callback);
  }

  /// This is called when the widget is clicked while app is in background
  @pragma('vm:entry-point')
  static Future<void> interactiveCallback(Uri? uri) async {
    // Actions can be handled here if needed for background tasks
  }
}