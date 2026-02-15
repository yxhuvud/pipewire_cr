require "../base"
require "../../lib/lib_spa"

module Pipewire
  module SPA
    class Dict < Base(LibSPA::Dict)
      include Enumerable(Tuple(String, String))
      include Indexable(Tuple(String, String))

      def initialize(@pointer : LibSPA::Dict*)
      end

      private def slice
        self.value.items.to_slice(self.value.n_items)
      end

      def size
        self.slice.size
      end

      def each(&)
        self.slice.each do |dict_item|
          yield({String.new(dict_item.key), String.new(dict_item.value)})
        end
      end

      def unsafe_fetch(index)
        self.slice.unsafe_fetch(index)
      end
    end
  end
end
