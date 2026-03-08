require "../lib/lib_pipewire"
require "./loop"

module Pipewire
  class MainLoop < Base(LibPipewire::MainLoop)
    def initialize(@pointer : LibPipewire::MainLoop*)
      super(@pointer)
    end

    def initialize
      super(LibPipewire.pw_main_loop_new(nil))
    end

    getter(loop : Loop) { Loop.new(LibPipewire.pw_main_loop_get_loop(self), false) }

    def finalize
      LibPipewire.pw_main_loop_destroy(self)
    end

    delegate process_all, create_context, to: loop

    def run
      LibPipewire.pw_main_loop_run(self)
    end

    def quit
      LibPipewire.pw_main_loop_quit(self)
    end
  end
end
