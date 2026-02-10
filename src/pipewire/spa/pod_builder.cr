require "../../lib/lib_spa"

module Pipewire
  module SPA
    class PodBuilder
      def initialize(data, size = data.size)
        @spa_pod_builder = LibSPA::PodBuilder.new(data: data.to_unsafe, size: size)
      end

      def to_unsafe
        pointerof(@spa_pod_builder)
      end
    end
  end
end
