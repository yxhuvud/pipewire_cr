require "../lib/lib_pipewire"
require "./context"

module Pipewire
  class ThreadLoop < Base(LibPipewire::ThreadLoop)
    def initialize(@pointer : LibPipewire::ThreadLoop*)
      super(@pointer)
    end

    def initialize(name : String)
      super(LibPipewire.pw_thread_loop_new(name, nil))
    end

    def loop
      LibPipewire.pw_thread_loop_get_loop(self)
    end

    def finalize
      stop
      LibPipewire.pw_thread_loop_destroy(self)
    end

    def start
      LibPipewire.pw_thread_loop_start(self)
    end

    def stop
      LibPipewire.pw_thread_loop_stop(self)
    end

    def lock
      LibPipewire.pw_thread_loop_lock(self)
    end

    def wait
      LibPipewire.pw_thread_loop_wait(self)
    end

    def lock(&)
      lock
      yield
    ensure
      unlock
    end

    def unlock
      LibPipewire.pw_thread_loop_unlock(self)
    end

    def create_context(properties = nil, user_data_size = 0) : Context
      Context.new(LibPipewire.pw_context_new(loop, properties, user_data_size))
    end
  end
end
