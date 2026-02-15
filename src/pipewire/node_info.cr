require "../lib/lib_pipewire"
require "./spa/dict"

module Pipewire
  class NodeInfo < Base(LibPipewire::NodeInfo)
    alias State = LibPipewire::NodeState

    value_getter id : UInt32
    value_getter max_input_ports : UInt32
    value_getter max_output_ports : UInt32
    value_getter change_mask : UInt64
    value_getter n_input_ports : UInt32
    value_getter n_output_ports : UInt32
    value_getter state : State
    value_getter error : String
    value_getter properties : SPA::Dict
    value_slice params : LibSPA::ParamInfo
  end
end
