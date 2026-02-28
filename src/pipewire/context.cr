require "./core"

module Pipewire
  class Context < Base(LibPipewire::Context)
    def connect(properties = nil, user_data_size = 0) : Core
      Core.new(LibPipewire.pw_context_connect(self, properties, user_data_size))
    end

    def connect(properties_as_hash : Hash, user_data_size = 0) : Core
      properties = Pipewire::Properties.new(properties_as_hash)
      connect(properties, user_data_size)
    end

    def finalize
      LibPipewire.pw_context_destroy(self)
    end
  end
end
