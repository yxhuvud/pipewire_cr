require "./pipewire/spa/pod_builder"
require "./pipewire/spa/type_info"
require "./pipewire/audio_format"
require "./pipewire/stream"
require "./pipewire/thread_loop"

module Pipewire
  VERSION = "0.1.0"

  SIZE = 1

  def self.init(name)
    args = [name.to_unsafe]
    LibPipewire.pw_init(pointerof(SIZE), args.to_unsafe)
  end

  def self.headers_version
    String.new(LibPipewire.pw_get_headers_version)
  end

  def self.library_version
    String.new(LibPipewire.pw_get_library_version)
  end
end
