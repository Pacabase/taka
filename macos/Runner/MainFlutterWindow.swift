import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  static var menuChannel: FlutterMethodChannel?

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    MainFlutterWindow.menuChannel = FlutterMethodChannel(
      name: "taka/menu", binaryMessenger: flutterViewController.engine.binaryMessenger)
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
