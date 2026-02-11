require "../../lib/lib_spa"
require "../base"

module Pipewire
  module SPA
    class PodBuilder < Base(LibSPA::PodBuilder)
      def initialize(data, size = data.size)
        @spa_pod_builder = LibSPA::PodBuilder.new(data: data.to_unsafe, size: size)
        @pointer = pointerof(@spa_pod_builder)
      end
    end
  end
end
