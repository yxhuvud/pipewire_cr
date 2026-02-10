Pipewire.init "hello"
main_loop = Pipewire::MainLoop.new
context = Pipewire::Context.new(main_loop)
core = Pipewire::Core.new(context)

stream_events = Pipewire::StreamEvents.new do
  p :hi
end

stream = Pipewire::Stream.new(
  main_loop,
  "audio-src",
  {
    Pipewire::PropertyKey::MEDIA_TYPE     => "Audio",
    Pipewire::PropertyKey::MEDIA_CATEGORY => "Playback",
    Pipewire::PropertyKey::MEDIA_ROLE     => "Music",
  },
  stream_events,
  nil
)

buffer = Slice(UInt8).new(1024)
pod_builder = Pipewire::SpaPodBuilder.new(buffer)
