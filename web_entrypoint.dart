import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:mentalsustainability/main.dart' as app;

void main() {
  // Use setUrlStrategy to remove the # from the URL
  setUrlStrategy(PathUrlStrategy());
  
  // Call the main app entry point
  app.main();
}
