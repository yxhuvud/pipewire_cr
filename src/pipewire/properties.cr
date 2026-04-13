require "../lib/lib_pipewire"
require "./base"
require "./property_key"

module Pipewire
  class Properties < Base(LibPipewire::Properties)
    def initialize(@pointer : LibPipewire::Properties*)
      super(@pointer)
    end

    def initialize(properties : Hash(PropertyKey, String?))
      dict = LibSPA::Dict.new(flags: 0, n_items: properties.size, items: properties.map do |key, value|
        LibSPA::DictItem.new(key: key.key, value: value.try(&.to_unsafe) || Pointer(LibC::Char).null)
      end)

      @pointer = LibPipewire.pw_properties_new_dict(pointerof(dict))
    end

    def finalize
      LibPipewire.pw_properties_free(self)
    end
  end
end
