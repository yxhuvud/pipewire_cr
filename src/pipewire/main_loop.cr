require "../lib/lib_pipewire"
require "./base"

module Pipewire
  class MainLoop < Base(LibPipewire::MainLoop)
    def initialize
      @pointer = LibPipewire.pw_main_loop_new(nil)
    end

    def loop
      LibPipewire.pw_main_loop_get_loop(self)
    end

    def finalize
      LibPipewire.pw_main_loop_destroy(self)
    end

    def process_all
      LibPipewire.pw_loop_enter(loop)
      fd = LibPipewire.pw_loop_get_fd(loop)
      file = IO::FileDescriptor.new(fd)
      event_loop = Crystal::EventLoop.current

      loop do
        p :a
        event_loop.wait_readable(file)
        res = LibPipewire.pw_loop_iterate(loop, 0)
        # positive = fds polled, so not interesting
        raise "error: #{res}" if res < 0
      end
    ensure
      LibPipewire.pw_loop_leave(loop)
    end

    def run
      LibPipewire.pw_main_loop_run(self)
    end

    def quit
      LibPipewire.pw_main_loop_quit(self)
    end
  end
end
