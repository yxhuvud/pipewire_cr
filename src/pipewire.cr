require "./lib/lib_pipewire"
require "json"

module Pipewire
  VERSION = "0.1.0"

  def self.init(name)
    size = 1
    args = [name.to_unsafe]
    LibPipewire.pw_init(pointerof(size), args.to_unsafe)
  end

  class Stream
    def self.new(main_loop : MainLoop, name, properties, stream_events, userdata = nil)
      new(main_loop.loop, name, properties, stream_events, userdata)
    end

    def initialize(loop : LibPipewire::Loop*, name, properties : Hash, stream_events, user_data)
      @stream = LibPipewire.pw_stream_new_simple(
        loop,
        name.to_unsafe,
        Properties.new(properties),
        stream_events,
        user_data
      )
    end

    PW_ID_ANY = 0xffffffffu32

    alias Flags = LibPipewire::StreamFlags
    alias State = LibPipewire::StreamState

    def connect(direction : LibPipewire::Direction,
                flags : Flags,
                format : LibPipewire::SpaAudioFormat = :spa_audio_format_s16,
                channels = :default,
                rate = :default,
                target : UInt32 = PW_ID_ANY)
      params = SpaAudioInfoRaw.new(
        format:,
        flags: 0,
        rate:,
        channels:,
        position:
          
      )
      LibPipewire.pw_stream_connect(
        self,
        direction,
        target,
        flags,
        params,
        1
      )
    end

    def to_unsafe
      @stream
    end
  end

  class StreamEvents(T)
    def initialize(@handler : T)
      @stream_events = LibPipewire::StreamEvent.new(
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

  @[Flags]
  enum PropertyKey
    MediaType
    MediaCategory
    MediaRole

    def to_json_object_key
      pipewire_key
    end

    def pipewire_key
      to_s.underscore.tr("_", ".")
    end
  end

  class Properties
    #    The properties are owned by the stream and freed when the stream is destroyed later.
    #
    # So may create GC issues?
    def initialize(properties : Hash(PropertyKey, String))
      @properties = properties
    end

    def to_unsafe
      LibPipewire.pw_properties_new_string(@properties.to_json.to_unsafe)
    end
  end

  class Core
    def self.new(context, properties = nil, userdata_size = 0)
      core = LibPipewire.pw_context_connect(context, properties, userdata_size)
      new(core)
    end

    def initialize(core : LibPipewire::Core*)
      @core = core
    end
  end

  class SpaPodBuilder
    def initialize(data, size = data.size)
      @spa_pod_builder = LibPipewire::SpaPodBuilder.new(data: data.to_unsafe, size: size)
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

    def to_unsafe
      @context
    end
  end
end
