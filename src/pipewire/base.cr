module Pipewire
  abstract class Base(T)
    @pointer : T*

    def initialize(@pointer : T*)
    end

    def value?
      !@pointer.null?
    end

    def value
      @pointer.value
    end

    macro value_getter(name_type)
      {% name = name_type.var %}
      {% value_type = name_type.type %}
      def {{ name }}
        {% if value_type.resolve <= parse_type("Pipewire::Base").resolve %}
          {{ value_type }}.new(self.value.{{ name }})
        {% else %}
          self.value.{{ name }}
        {% end %}
      end
    end

    class Slice(T, U)
      include Enumerable(T)
      include Indexable(T)

      getter size : UInt32

      def initialize(@pointer : Pointer(U), @size : UInt32)
      end

      def unsafe_fetch(index)
        T.new(@pointer + index)
      end

      def each(&)
        size.times do |i|
          yield self.unsafe_fetch(i)
        end
      end
    end

    macro value_slice(name_type, size_name)
      {% name = name_type.var %}
      {% value_type = name_type.type %}
      def {{ name }}
        {% if value_type.resolve <= parse_type("Pipewire::Base").resolve %}
          {% base_type = value_type.resolve.ancestors.find { |a| a.name(generic_args: false) == "Pipewire::Base" }.type_vars.first %}
          Pipewire::Base::Slice({{ value_type }}, {{ base_type }}).new(self.value.{{ name }}, self.value.{{ size_name.id }})
        {% else %}
          self.value.{{ name }}.to_slice(self.value.{{ size_name }})
        {% end %}
      end
    end

    def to_unsafe
      @pointer
    end
  end
end
