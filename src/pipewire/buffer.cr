require "./base"

module Pipewire
  class Buffer < Base(LibPipewire::Buffer)
  end
end
