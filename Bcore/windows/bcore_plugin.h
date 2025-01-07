#ifndef FLUTTER_PLUGIN_bcore_PLUGIN_H_
#define FLUTTER_PLUGIN_bcore_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace bcore {

class BcoreDesktopPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  BcoreDesktopPlugin();

  virtual ~BcoreDesktopPlugin();

  // Disallow copy and assign.
  BcoreDesktopPlugin(const BcoreDesktopPlugin&) = delete;
  BcoreDesktopPlugin& operator=(const BcoreDesktopPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace bcore

#endif  // FLUTTER_PLUGIN_bcore_PLUGIN_H_
