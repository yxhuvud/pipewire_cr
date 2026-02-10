require "./lib/lib_pipewire"
require "./pipewire/spa/pod_builder"
require "./pipewire/audio_format"
require "./pipewire/stream"
require "./pipewire/context"

module Pipewire
  VERSION = "0.1.0"

  SIZE = 1

  def self.init(name)
    args = [name.to_unsafe]
    LibPipewire.pw_init(pointerof(SIZE), args.to_unsafe)
  end
end
