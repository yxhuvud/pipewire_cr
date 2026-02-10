require "../lib/lib_pipewire"
require "./property_key"

module Pipewire
  class Properties
    def initialize(properties : Hash(PropertyKey, String))
      dict = LibSPA::Dict.new(flags: 0, n_items: properties.size, items: properties.map do |key, value|
        LibSPA::DictItem.new(key: key.key, value: value)
      end)

      @properties = LibPipewire.pw_properties_new_dict(pointerof(dict))
    end

    def to_unsafe
      @properties
    end
  end
end
