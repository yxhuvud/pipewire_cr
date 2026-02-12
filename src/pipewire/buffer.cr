require "./spa/buffer"

module Pipewire
  class Buffer < Base(LibPipewire::Buffer)
    value_getter buffer : SPA::Buffer
    value_getter user_data : Void*
    value_getter size : UInt64
    value_getter requested : UInt64
    value_getter time : UInt64
  end
end
