require "../src/pipewire"

Pipewire.init("tutorial5")
main_loop = Pipewire::MainLoop.new
context = main_loop.create_context
core = context.connect
stream = core.create_stream("video-capture", {
  Pipewire::PropertyKey::MEDIA_TYPE     => "Video",
  Pipewire::PropertyKey::MEDIA_CATEGORY => "Capture",
  Pipewire::PropertyKey::MEDIA_ROLE     => "Camera",
})

accumulator = 0f64

listener = stream.on_process do
  b = stream.dequeue_buffer
  if b.value?
    buf = b.buffer
    ptr = buf.datas[0].data
    next unless ptr
    puts "got a frame of size %d" % buf.datas[0].chunk.value.size

    stream.queue_buffer(b)
  end
end

config_change = stream.on_param_changed do |id, param|
  next unless id.format?
  params = param.to_value.as(Hash)

  puts "format changed:"
  if params["mediaType"] == "video" && params["mediaSubtype"] == "raw"
    puts "got video format:"
    puts "  format: #{params["format"]}"
    puts "  size: #{params["size"]}"
    puts "  framerate: #{params["framerate"]}" # TODO, it is still a choice :(
  end
end

buffer = Slice(UInt8).new(1024)

pod = Pipewire::SPA::Pod.format do |f|
  f.media_type :video
  f.media_subtype :raw
  f.video_format :rgb, :rgba, :rgbx, :bgrx, :yuy2, :i420
  f.video_size(default: {320, 240}, min: {1, 1}, max: {4096, 4096})
  f.video_framerate(default: {25, 1}, min: {0, 1}, max: {1000, 1})
end

stream.connect(
  direction: :input,
  flags: Pipewire::Stream::Flag::Autoconnect | Pipewire::Stream::Flag::MapBuffers,
  params: [pod]
)

main_loop.process_all
