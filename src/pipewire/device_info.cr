require "../lib/lib_pipewire"
require "./spa/dict"
require "./spa/param_info"

module Pipewire
  class DeviceInfo < Base(LibPipewire::DeviceInfo)
    value_getter id : UInt32
    value_getter change_mask : LibPipewire::DeviceChangeMask
    value_getter properties : SPA::Dict
    value_slice params : SPA::ParamInfo
  end
end
