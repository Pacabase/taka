import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  @IBAction func showAbout(_ sender: Any?) {
    MainFlutterWindow.menuChannel?.invokeMethod("about", arguments: nil)
  }

  @IBAction func showSettings(_ sender: Any?) {
    MainFlutterWindow.menuChannel?.invokeMethod("settings", arguments: nil)
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
