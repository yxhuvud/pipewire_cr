require "../lib/lib_pipewire"
require "./spa/dict"

module Pipewire
  class ClientInfo < Base(LibPipewire::ClientInfo)
    value_getter id : UInt32
    value_getter change_mask : LibPipewire::ClientChangeMask
    value_getter properties : SPA::Dict
  end
end
