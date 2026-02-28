require "../../lib/lib_spa"
require "../base"

class Pipewire::SPA::TypeInfoList < Pipewire::Base(Pipewire::LibSPA::TypeInfo)
end

module Pipewire
  module SPA
    class TypeInfo < Base(LibSPA::TypeInfo)
      value_getter type : UInt32
      value_getter parent : UInt32
      value_getter name : String
      value_getter values : TypeInfoList

      def valid_id?
        type != LibSPA::ID_INVALID
      end

      def short_name
        self.name.split(':')[-1]
      end
    end
  end
end

module Pipewire
  module SPA
    class TypeInfoList < Base(LibSPA::TypeInfo)
      include Enumerable(TypeInfo)
      include Indexable(TypeInfo)

      def initialize(@pointer : LibSPA::TypeInfo*)
      end

      def self.root
        new(LibSPA.spa_shim_type_root)
      end

      @size : Int32?

      def size : Int32
        @size ||=
          if !self.to_unsafe.null?
            elements = 0
            while !self.to_unsafe[elements].name.null?
              elements += 1
            end
            elements
          else
            0
          end
      end

      def each(&)
        self.size.times do |index|
          yield TypeInfo.new(self.to_unsafe + index)
        end
      end

      def unsafe_fetch(index)
        TypeInfo.new(self.to_unsafe + index)
      end

      def find_type(type : UInt32)
        find do |type_info|
          next type_info.type == type if type_info.valid_id?

          type_info.values.find_type(type)
        end
      end
    end
  end
end
