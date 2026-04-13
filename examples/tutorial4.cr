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

pod = Pipewire::SPA::Pod.build do |p|
  p.object(Pipewire::LibSPA::PodObjectType::Format, Pipewire::LibSPA::ParamType::EnumFormat) do
    p.prop(Pipewire::LibSPA::Format::MediaType) { p.id(Pipewire::LibSPA::MediaType::Audio) }
    p.prop(Pipewire::LibSPA::Format::MediaSubtype) { p.id(Pipewire::LibSPA::MediaSubType::Raw) }
    p.prop(Pipewire::LibSPA::Format::AUDIO_format) { p.id(Pipewire::LibSPA::AudioFormat::S16) }
    p.prop(Pipewire::LibSPA::Format::AUDIO_channels) { p.int(CHANNELS) }
    p.prop(Pipewire::LibSPA::Format::AUDIO_rate) { p.int(RATE) }
  end
end

stream.connect(
  direction: :output,
  flags: Pipewire::Stream::Flag::Autoconnect | Pipewire::Stream::Flag::MapBuffers,
  params: [pod]
)

accumulator = 0f64

stream.on_process do
  b = stream.dequeue_buffer
  if b.value?
    buf = b.buffer
    ptr = buf.datas[0].data

    stride = sizeof(Int16)*CHANNELS
    n_frames = buf.datas[0].maxsize // stride
    if b.requested != 0
      n_frames = {b.requested, n_frames}.min
    end

    n_frames.times do |i|
      accumulator += 2 * Math::PI * 440 / RATE
      if accumulator >= 2 * Math::PI
        accumulator -= 2 * Math::PI
      end
      val = (Math.sin(accumulator) * VOLUME * 32767.0).to_i16
      CHANNELS.times do |c|
        ptr.as(Pointer(Int16))[i*CHANNELS + c] = val
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

main_loop.process_all
