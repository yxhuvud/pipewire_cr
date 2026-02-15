require "../base"
require "../../lib/lib_spa"

module Pipewire
  module SPA
    class Buffer < Base(LibSPA::Buffer)
      value_slice metas : LibSPA::Meta
      value_slice datas : LibSPA::Data
    end
  end
end
