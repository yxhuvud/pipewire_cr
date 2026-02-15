require "./node_info"
require "./event_listener"

module Pipewire
  class Node < Base(LibPipewire::Node)
    include EventListener

    EVENT_LISTENER_VERSION = LibPipewire::VERSION_NODE_EVENTS

    event_listener info : NodeInfo -> Void
    event_listener param : Int32, UInt32, UInt32, UInt32, LibSPA::Pod -> Void

    def subscribe_params(ids : Array)
      LibPipewire.pw_node_subscribe_params(self, ids, ids.size)
    end

    def finalize
      LibPipewire.pw_proxy_destroy(self.to_unsafe.as(Pointer(LibPipewire::Proxy)))
    end
  end
end
