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
    Pipewire::PropertyKey::MediaType     => "Audio",
    Pipewire::PropertyKey::MediaCategory => "Playback",
    Pipewire::PropertyKey::MediaRole     => "Music",
  },
  stream_events
  nil
)


buffer = Slice(UInt8).new(1024)
pod_builder = Pipewire::SpaPodBuilder.new(buffer)
