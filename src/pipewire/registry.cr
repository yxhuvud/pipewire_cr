require "./spa/dict"
require "./client"
require "./node"

module Pipewire
  class Registry < Base(LibPipewire::Registry)
    include EventListener

    EVENT_LISTENER_VERSION = LibPipewire::VERSION_REGISTRY_EVENTS

    event_listener global : UInt32, UInt32, String, UInt32, SPA::Dict -> Void
    event_listener global_remove : UInt32 -> Void

    def bind_node(id, item_type) : Node
      Node.new(LibPipewire.pw_registry_bind(self, id, item_type, LibPipewire::VERSION_NODE, 0).as(LibPipewire::Node*))
    end

    def bind_client(id, item_type) : Client
      Client.new(LibPipewire.pw_registry_bind(self, id, item_type, LibPipewire::VERSION_CLIENT, 0).as(LibPipewire::Client*))
    end

    def finalize
      LibPipewire.pw_proxy_destroy(self.to_unsafe.as(Pointer(LibPipewire::Proxy)))
    end
  end
end
