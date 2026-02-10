require "./registry"

module Pipewire
  class Core
    def initialize(core : LibPipewire::Core*)
      @core = core
    end

    def registry
      Registry.new(LibPipewire.pw_core_get_registry(@core, LibPipewire::VERSION_REGISTRY, 0))
    end

    def to_unsafe
      @core
    end

    def finalize
      LibPipewire.pw_core_disconnect(self)
    end
  end
end
