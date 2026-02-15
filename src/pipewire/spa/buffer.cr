require "../base"
require "../../lib/lib_spa"

module Pipewire
  module SPA
    class Buffer < Base(LibSPA::Buffer)
      value_slice metas : LibSPA::Meta, n_metas
      value_slice datas : LibSPA::Data, n_datas
    end
  end
end
