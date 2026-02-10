require "../src/pipewire"

RATE     = 44100
CHANNELS =     2
VOLUME   =   0.7

Pipewire.init("tutorial4")
main_loop = Pipewire::MainLoop.new
context = main_loop.create_context
core = context.connect
stream = core.create_stream("audio-src", {
  Pipewire::PropertyKey::MEDIA_TYPE     => "Audio",
  Pipewire::PropertyKey::MEDIA_CATEGORY => "Playback",
  Pipewire::PropertyKey::MEDIA_ROLE     => "Music",
})

accumulator = 0f64

listener = stream.on_process do
  b = stream.dequeue_buffer

  if !b.value?
    buf = b.buffer
    ptr = buf.datas[0].data

    stride = sizeof(Int16)*CHANNELS
    n_frames = buf.datas[0].maxsize//stride
    if b.requested != 0
      n_frames = [b.requested, n_frames].min
    end

    n_frames.times do
      accumulator += 2*Math::PI * 440 / RATE
      if accumulator >= 2*Math::PI
        accumulator -= 2*Math::PI
      end
      val = (Math.sin(accumulator) * VOLUME * 32767.0).to_i16
      CHANNELS.times do
        ptr.as(Pointer(Int16)).value = val
        ptr += 1
      end
    end

    buf.datas[0].chunk.value.offset = 0
    buf.datas[0].chunk.value.stride = stride
    buf.datas[0].chunk.value.size = n_frames * stride

    stream.queue_buffer(b)
  else
    puts "out of buffers"
  end
end

buffer = Slice(UInt8).new(1024)
pod_builder = Pipewire::SPA::PodBuilder.new(buffer)

audio_info_raw = Pipewire::LibSPA::AudioInfoRaw.new(format: Pipewire::LibSPA::AudioFormat::S16, channels: CHANNELS, rate: RATE)
pod = Pipewire::LibSPA.spa_format_audio_raw_build(pod_builder, Pipewire::LibSPA::ParamType::EnumFormat, pointerof(audio_info_raw))
params = [pod]

stream.connect(direction: :output, flags: Pipewire::Stream::Flag::Autoconnect | Pipewire::Stream::Flag::MapBuffers, params: params)

main_loop.process_all
