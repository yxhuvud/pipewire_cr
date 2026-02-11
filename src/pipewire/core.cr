require "./registry"

module Pipewire
  class Core < Base(LibPipewire::Core)
    def registry
      Registry.new(LibPipewire.pw_core_get_registry(self, LibPipewire::VERSION_REGISTRY, 0))
    end

    def finalize
      LibPipewire.pw_core_disconnect(self)
    end
  end
end
