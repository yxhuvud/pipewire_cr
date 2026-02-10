require "./lib/lib_pipewire"
require "./pipewire/property_key"
require "./pipewire/registry"
require "json"

module Pipewire
  VERSION = "0.1.0"

  alias AudioFormat = LibSPA::AudioFormat
  SIZE = 1

  def self.init(name)
    args = [name.to_unsafe]
    LibPipewire.pw_init(pointerof(SIZE), args.to_unsafe)
  end

  class Stream
    def self.new(main_loop : MainLoop, name, properties, stream_events, userdata = nil)
      new(main_loop.loop, name, properties, stream_events, userdata)
    end

    def initialize(loop : LibPipewire::Loop*, name, properties : Hash, stream_events, user_data)
      @properties = Properties.new(properties)
      @stream = LibPipewire.pw_stream_new_simple(
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

    def to_unsafe
      @stream
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

  class Properties
    def initialize(properties : Hash(PropertyKey, String))
      @properties = properties
    end

    def to_unsafe
      LibPipewire.pw_properties_new_string(@properties.to_json.to_unsafe)
    end
  end

  class Core
    def initialize(core : LibPipewire::Core*)
      @core = core
    end

    def registry
      Registry.new(LibPipewire.pw_core_get_registry(@core, LibPipewire::VERSION_REGISTRY, 0))
    end

    def to_unsafe
      @core
    end
  end

  class SpaPodBuilder
    def initialize(data, size = data.size)
      @spa_pod_builder = LibSPA::PodBuilder.new(data: data.to_unsafe, size: size)
    end

    def to_unsafe
      pointerof(@spa_pod_builder)
    end
  end

  class MainLoop
    def initialize
      @loop = LibPipewire.pw_main_loop_new(nil)
    end

    def loop
      LibPipewire.pw_main_loop_get_loop(self)
    end

    def to_unsafe
      @loop
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
  end

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
  end
end
