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

    macro value_slice(pointer_name, size_name)
      def {{ pointer_name }}
        self.value.{{ pointer_name }}.to_slice(self.value.{{ size_name }})
      end
    end

    def to_unsafe
      @pointer
    end
  end
end
