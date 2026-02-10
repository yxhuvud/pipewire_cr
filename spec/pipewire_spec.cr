require "./spec_helper"

class Handler
  def initialize
  end

  def process
    p :hi
  end
end

describe Pipewire do
  # TODO: Write tests
  it "can enumerate objects" do
    # https://docs.pipewire.org/page_tutorial2.html
    Pipewire.init "hello"
    main_loop = Pipewire::MainLoop.new
    context = Pipewire::Context.new(main_loop)
    core = Pipewire::Core.new(context)
    #     registry = pw_core_get_registry(core, PW_VERSION_REGISTRY,
    #                 0 /* user_data size */);

    # spa_zero(registry_listener);
    # pw_registry_add_listener(registry, &registry_listener,
    #                                &registry_events, NULL);

    # pw_main_loop_run(loop);

    # pw_proxy_destroy((struct pw_proxy*)registry);
    # pw_core_disconnect(core);
    # pw_context_destroy(context);
    # pw_main_loop_destroy(loop);

    # return 0;
  end

  it "can do a roundtrip" do
    # https://docs.pipewire.org/page_tutorial3.html
    Pipewire.init "hello"
    main_loop = Pipewire::MainLoop.new
    context = Pipewire::Context.new(main_loop)
    core = Pipewire::Core.new(context)
  end

  it "can play a jig" do
    # https://docs.pipewire.org/page_tutorial4.html
    handler = Handler.new
    # TODO: Extract system defaults
    rate = 44100
    channels = 2
    volume = 0.7

    Pipewire.init "hello"
    main_loop = Pipewire::MainLoop.new

    buffer = Slice(UInt8).new(1024)
    pod_builder = Pipewire::SpaPodBuilder.new(buffer)

    stream_events = Pipewire::StreamEvents(Handler).new(handler)
    stream = Pipewire::Stream.new(
      main_loop,
      "audio-src",
      {
        Pipewire::PropertyKey::MediaType     => "Audio",
        Pipewire::PropertyKey::MediaCategory => "Playback",
        Pipewire::PropertyKey::MediaRole     => "Music",
      },
      stream_events
    )

    positions = StaticArray(UInt32, Pipewire::LibSPA::MAX_CHANNELS).new { 0u32 }
    info = Pipewire::LibSPA::SpaAudioInfoRaw.new(
      format: Pipewire::AudioFormat::SPA_AUDIO_FORMAT_S16,
      rate: rate,
      channels: channels,
      position: positions
    )
    pod = Pipewire::LibSPA.spa_format_audio_raw_build(
      pod_builder,
      Pipewire::LibSPA::SpaParamType::EnumFormat,
      pointerof(info),
    )
    params = [pod]

    stream.connect(
      params: params,
      direction: Pipewire::LibPipewire::Direction::Output,
      flags: Pipewire::Stream::Flags::Autoconnect |
      Pipewire::Stream::Flags::MapBuffers 
    )
    main_loop.process_all
  end

  it "can capture video frames" do
    # https://docs.pipewire.org/page_tutorial5.html
  end

  it "can bind to objects so that events are received" do
    # https://docs.pipewire.org/page_tutorial6.html
  end
end
