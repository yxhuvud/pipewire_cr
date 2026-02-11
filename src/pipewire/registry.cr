require "../lib/lib_pipewire"
require "./base"
require "./event_listener"

module Pipewire
  class Registry < Base(LibPipewire::Registry)
    include EventListener

    EVENT_LISTENER_VERSION = LibPipewire::VERSION_REGISTRY_EVENTS

    event_listener global : UInt32, UInt32, String, UInt32, Pipewire::LibSPA::Dict -> Void
    event_listener global_remove : UInt32 -> Void

    def finalize
      LibPipewire.pw_proxy_destroy(self.to_unsafe.as(Pointer(LibPipewire::Proxy)))
    end
  end
end
