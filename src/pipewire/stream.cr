require "./buffer"
require "./properties"
require "./main_loop"

module Pipewire
  class Stream < Base(LibPipewire::Stream)
    def self.new(main_loop : MainLoop, name, properties, stream_events, userdata = nil)
      new(main_loop.loop, name, properties, stream_events, userdata)
    end

    def initialize(core : Core, name, properties)
      @properties = Properties.new(properties)
      @pointer = LibPipewire.pw_stream_new(core, name, @properties)
    end

    def initialize(loop : LibPipewire::Loop*, name, properties : Hash, stream_events, user_data)
      @properties = Properties.new(properties)
      @pointer = LibPipewire.pw_stream_new_simple(
        loop,
        name.to_unsafe,
        @properties,
        stream_events,
        user_data
      )
    end

    alias Flag = LibPipewire::StreamFlag
    alias State = LibPipewire::StreamState

    include EventListener

    EVENT_LISTENER_VERSION = LibPipewire::VERSION_STREAM_EVENTS

    event_listener destroy : -> Void
    event_listener state_changed : LibPipewire::StreamState, LibPipewire::StreamState, String -> Void
    event_listener control_info : UInt32, LibPipewire::StreamControl -> Void
    event_listener io_changed : UInt32, Void*, UInt32 -> Void
    event_listener param_changed : UInt32, LibSPA::Pod -> Void
    event_listener add_buffer : LibPipewire::Buffer -> Void
    event_listener remove_buffer : LibPipewire::Buffer -> Void
    event_listener process : -> Void
    event_listener drained : -> Void
    event_listener command : LibSPA::Command -> Void
    event_listener trigger_done : -> Void

    def connect(params : Array(Pipewire::LibSPA::Pod*),
                direction : LibPipewire::Direction,
                target : UInt32 = LibPipewire::ID_ANY,
                flags : Flag = :none)
      LibPipewire.pw_stream_connect(
        self,
        direction,
        target,
        flags,
        params,
        params.size)
    end

    def dequeue_buffer
      Buffer.new(Pipewire::LibPipewire.pw_stream_dequeue_buffer(self))
    end

    def queue_buffer(buffer)
      Pipewire::LibPipewire.pw_stream_queue_buffer(self, buffer)
    end
  end
end
