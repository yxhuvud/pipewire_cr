require "../lib/lib_pipewire"
require "./context"

module Pipewire
  class Loop < Base(LibPipewire::Loop)
    @should_destroy : Bool

    def initialize(@pointer : LibPipewire::Loop*, @should_destroy : Bool = true)
      super(@pointer)
    end

    def finalize
      if @should_destroy
        LibPipewire.pw_loop_destroy(self)
      end
    end

    def enter
      LibPipewire.pw_loop_enter(self)
    end

    def fd
      LibPipewire.pw_loop_get_fd(self)
    end

    def iterate(timeout = 0)
      LibPipewire.pw_loop_iterate(self, timeout)
    end

    def leave
      LibPipewire.pw_loop_leave(self)
    end

    def process_all
      enter
      file = IO::FileDescriptor.new(fd)
      event_loop = Crystal::EventLoop.current

      loop do
        event_loop.wait_readable(file)
        res = iterate
        # positive = fds polled, so not interesting
        raise "error: #{res}" if res < 0
      end
    ensure
      leave
    end

    def create_context(properties = nil, user_data_size = 0) : Context
      Context.new(LibPipewire.pw_context_new(self, properties, user_data_size))
    end
  end
end
