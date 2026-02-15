require "../../lib/lib_spa"
require "../base"

module Pipewire
  module SPA
    class ParamInfo < Base(LibSPA::ParamInfo)
      value_getter id : LibSPA::ParamType
      value_getter flags : UInt32
      value_getter user : UInt32
      value_getter seq : Int32
      value_getter padding : UInt32[4]
    end
  end
end
