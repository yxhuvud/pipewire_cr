require "./registry"
require "./event_listener"

module Pipewire
  class Core < Base(LibPipewire::Core)
    include EventListener

    EVENT_LISTENER_VERSION = LibPipewire::VERSION_CORE_EVENTS

    event_listener info : LibPipewire::CoreInfo -> Void
    event_listener done : UInt32, LibC::Int -> Void
    event_listener ping : UInt32, LibC::Int -> Void
    event_listener error : UInt32, LibC::Int, LibC::Int, String -> Void
    event_listener remove_id : UInt32 -> Void
    event_listener bound_id : UInt32, UInt32 -> Void
    event_listener add_mem : UInt32, UInt32, LibC::Int, UInt32 -> Void
    event_listener remove_mem : UInt32 -> Void
    event_listener bound_props : UInt32, UInt32, LibSPA::Dict -> Void

    def registry
      Registry.new(LibPipewire.pw_core_get_registry(self, LibPipewire::VERSION_REGISTRY, 0))
    end

    def sync(seq)
      LibPipewire.pw_core_sync(self, LibPipewire::ID_CORE, seq)
    end

    def finalize
      LibPipewire.pw_core_disconnect(self)
    end
  end
end
