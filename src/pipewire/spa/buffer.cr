require "../base"
require "../../lib/lib_spa"

module Pipewire
  module SPA
    class Buffer < Base(LibSPA::Buffer)
      value_slice metas, n_metas
      value_slice datas, n_datas
    end
  end
end
