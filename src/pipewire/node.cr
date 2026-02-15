require "./node_info"
require "./event_listener"

module Pipewire
  class Node < Base(LibPipewire::Node)
    include EventListener

    EVENT_LISTENER_VERSION = LibPipewire::VERSION_NODE_EVENTS

    event_listener info : NodeInfo -> Void
    event_listener param : Int32, LibSPA::ParamType, UInt32, UInt32, LibSPA::Pod -> Void

    def subscribe_params(ids : Array(Pipewire::LibSPA::ParamType))
      LibPipewire.pw_node_subscribe_params(self, ids.map(&.to_i.to_u), ids.size)
    end

    def finalize
      LibPipewire.pw_proxy_destroy(self.to_unsafe.as(Pointer(LibPipewire::Proxy)))
    end
  end
end
