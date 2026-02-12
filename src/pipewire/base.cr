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

    def to_unsafe
      @pointer
    end
  end
end
