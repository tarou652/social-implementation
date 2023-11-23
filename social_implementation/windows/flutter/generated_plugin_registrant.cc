//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <audioplayers_windows/audioplayers_windows_plugin.h>
<<<<<<< HEAD
=======
#include <record_windows/record_windows_plugin_c_api.h>
>>>>>>> 24d222b8052f62d37e08970e235bd5fbf88f4f7e

void RegisterPlugins(flutter::PluginRegistry* registry) {
  AudioplayersWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AudioplayersWindowsPlugin"));
<<<<<<< HEAD
=======
  RecordWindowsPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("RecordWindowsPluginCApi"));
>>>>>>> 24d222b8052f62d37e08970e235bd5fbf88f4f7e
}
