require "./event_listener"
require "./client_info"

module Pipewire
  class Client < Base(LibPipewire::Client)
    include EventListener

    EVENT_LISTENER_VERSION = LibPipewire::VERSION_CLIENT_EVENTS

    event_listener info : ClientInfo -> Void
    event_listener permissions : UInt32, UInt32, LibPipewire::Permissions -> Void

    def finalize
      LibPipewire.pw_proxy_destroy(self.to_unsafe.as(Pointer(LibPipewire::Proxy)))
    end
  end
end
