require "../lib/lib_pipewire"
require "./loop"

module Pipewire
  class ThreadLoop < Base(LibPipewire::ThreadLoop)
    def initialize(@pointer : LibPipewire::ThreadLoop*)
      super(@pointer)
    end

    def initialize(name : String)
      super(LibPipewire.pw_thread_loop_new(name, nil))
    end

    getter(loop : Loop) { Loop.new(LibPipewire.pw_main_loop_get_loop(self), false) }

    delegate create_context, to: loop

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
  end
end
