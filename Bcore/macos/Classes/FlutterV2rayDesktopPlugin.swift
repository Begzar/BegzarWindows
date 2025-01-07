import Cocoa
import FlutterMacOS

public class BcoreDesktopPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "bcore", binaryMessenger: registrar.messenger)
    let instance = BcoreDesktopPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func getResourcePath() -> String? {
      let bundle = Bundle(for: BcoreDesktopPlugin.self)
      
      // Check the architecture of the device
      #if arch(x86_64)
          // 64-bit Mac
          if let resourcePath = bundle.path(forResource: "x64", ofType: nil, inDirectory: "Resources") {
              return resourcePath
          }
      #elseif arch(arm64)
          // ARM64 Mac
          if let resourcePath = bundle.path(forResource: "arm64", ofType: nil, inDirectory: "Resources") {
              return resourcePath
          }
      #endif
      return nil
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getSingPath":
      if let resourcePath = getResourcePath() {
        result(resourcePath)
      } else {
        result(nil)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
