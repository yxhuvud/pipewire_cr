require "./properties"
require "./main_loop"

module Pipewire
  class Stream < Base(LibPipewire::Stream)
    def self.new(main_loop : MainLoop, name, properties, stream_events, userdata = nil)
      new(main_loop.loop, name, properties, stream_events, userdata)
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
  end

  class StreamEvents(T)
    def initialize(@handler : T)
      @stream_events = LibPipewire::StreamEvents.new(
        version: 2,
        process: process_proc
      )
    end

    private def process_proc
      Proc(Void*, Void).new do |data|
        instance = data.as(T)
        instance.process
      end
    end

    def to_unsafe
      pointerof(@stream_events)
    end
  end
end
