require "./null_pointer_error"

module Pipewire
  abstract class Base(T)
    @pointer : T*

    def initialize(@pointer : T*)
      if @pointer.null?
        raise NullPointerError.new
      end
    end

    # Returns `true` if the underlying pointer is not a null-pointer, otherwise `true`.
    def value?
      !@pointer.null?
    end

    # Returns the value of the underlying pointer.
    def value
      @pointer.value
    end

    # Defines a getter method that delegates to the method with the same name on the pointer value.
    #
    # The argument is a type node with the name and the return type.
    # If the return type inherits `Base`, the object returned by the pointer value method is wrapped in the return type.
    # If the return type is `String`, the object returned by the pointer value method is passed to `String.new` (intended for `LibC::Char*`).
    # Otherwise, the object returned by the pointer value method is returned.
    macro value_getter(name_type)
      {% name = name_type.var %}
      {% value_type = name_type.type %}
      def {{ name }} : {{ value_type }}
        {% if value_type.resolve <= parse_type("Pipewire::Base").resolve %}
          {{ value_type }}.new(self.value.{{ name }})
        {% elsif value_type.resolve == String %}
          String.new(self.value.{{ name }})
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

    # Defines a getter method similar to `value_getter`, but wraps the values into a `Slice`.
    #
    # The first argument is a type node containing the name and the iteration type.
    # The iteration type must inherit `Base`.
    # The second argument is optional and defaults to `n_#{name}`, which seems to be the standard naming scheme in the Pipewire API.
    #
    # Usage:
    # ```
    # value_slice items : ItemType, n_items
    # ```
    macro value_slice(name_type, size_name = nil)
      {% name = name_type.var %}
      {% value_type = name_type.type %}
      {% size_name ||= "n_#{name}" %}
      def {{ name }}
        {% if value_type.resolve <= parse_type("Pipewire::Base").resolve %}
          {% base_type = value_type.resolve.ancestors.find { |a| a.name(generic_args: false) == "Pipewire::Base" }.type_vars.first %}
          Pipewire::Base::Slice({{ value_type }}, {{ base_type }}).new(self.value.{{ name }}, self.value.{{ size_name.id }})
        {% else %}
          self.value.{{ name }}.to_slice(self.value.{{ size_name.id }})
        {% end %}
      end
    end

    def to_unsafe
      @pointer
    end
  end
end
