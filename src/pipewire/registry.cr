require "../lib/lib_pipewire"

module Pipewire
  class Registry
    def initialize(@registry : LibPipewire::Registry*)
    end

    class EventListenerGlobal
      def initialize(@registry : Registry, callback : UInt32, UInt32, String, UInt32, Pipewire::LibSPA::Dict -> Void)
        @hook = LibSPA::Hook.new
        @box = Box.box(callback)
        @events = LibPipewire::RegistryEvents.new(version: LibPipewire::VERSION_REGISTRY_EVENTS, global: ->(data : Void*, id : UInt32, permissions : UInt32, item_type : LibC::Char*, version : UInt32, props : Pipewire::LibSPA::Dict*) do
          cb = Box(typeof(callback)).unbox(data)
          cb.call(id, permissions, String.new(item_type), version, props.value)
        end)

        LibPipewire.pw_registry_add_listener(@registry, pointerof(@hook), pointerof(@events), @box)
      end
    end

    protected getter event_listeners_global = [] of EventListenerGlobal

    def on_global(&callback : UInt32, UInt32, String, UInt32, Pipewire::LibSPA::Dict -> Void)
      self.event_listeners_global << EventListenerGlobal.new(self, callback)
    end

    class EventListenerGlobalRemove
      def initialize(@registry : Registry, callback : UInt32 -> Void)
        @hook = LibSPA::Hook.new
        @box = Box.box(callback)
        @events = LibPipewire::RegistryEvents.new(version: LibPipewire::VERSION_REGISTRY_EVENTS, global_remove: ->(data : Void*, id : UInt32) do
          cb = Box(typeof(callback)).unbox(data)
          cb.call(id)
        end)

        LibPipewire.pw_registry_add_listener(@registry, pointerof(@hook), pointerof(@events), @box)
      end
    end

    protected getter event_listeners_global_remove = [] of EventListenerGlobalRemove

    def on_global_remove(&callback : UInt32 -> Void)
      self.event_listeners_global_remove << EventListenerGlobalRemove.new(self, callback)
    end

    def to_unsafe
      @registry
    end

    def finalize
      LibPipewire.pw_proxy_destroy(@registry.as(Pointer(LibPipewire::Proxy)))
    end
  end
end
