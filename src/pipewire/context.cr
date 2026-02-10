require "./core"

module Pipewire
  class Context
    def self.new(main_loop : MainLoop, properties = nil, userdata_size = 0)
      new(main_loop.loop, properties, userdata_size)
    end

    def initialize(loop, properties = nil, userdata_size = 0)
      @context = LibPipewire.pw_context_new(
        loop,
        properties,
        userdata_size
      )
    end

    def connect(properties = nil, user_data_size = 0)
      Core.new(LibPipewire.pw_context_connect(self, properties, user_data_size))
    end

    def to_unsafe
      @context
    end

    def finalize
      LibPipewire.pw_context_destroy(self)
    end
  end
end
