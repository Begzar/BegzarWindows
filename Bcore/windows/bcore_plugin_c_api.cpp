#include "include/bcore/bcore_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "bcore_plugin.h"

void BcoreDesktopPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  bcore::BcoreDesktopPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
